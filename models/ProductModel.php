    <?php
require_once 'utils/Database.php';

class ProductModel {
    private $db;
    
    public function __construct() {
        $this->db = (new Database())->getConnection();
    }
    
    public function getProducts($filters = [], $page = 1, $limit = 10) {
        $offset = ($page - 1) * $limit;
        $whereClause = "WHERE p.is_active = TRUE";
        $params = [];

        if (!empty($filters['category_id'])) {
            $whereClause .= " AND p.category_id = :category_id";
            $params[':category_id'] = $filters['category_id'];
        }

        if (!empty($filters['min_price'])) {
            $whereClause .= " AND p.price >= :min_price";
            $params[':min_price'] = $filters['min_price'];
        }

        if (!empty($filters['max_price'])) {
            $whereClause .= " AND p.price <= :max_price";
            $params[':max_price'] = $filters['max_price'];
        }

        if (!empty($filters['search'])) {
            $whereClause .= " AND (p.product_name LIKE :search OR p.description LIKE :search)";
            $params[':search'] = '%' . $filters['search'] . '%';
        }

        // 🔹 Thêm ORDER BY theo sort
        $orderBy = "ORDER BY p.created_at DESC"; // mặc định
        if (!empty($filters['sort'])) {
            if ($filters['sort'] === 'asc') {
                $orderBy = "ORDER BY p.price ASC";
            } elseif ($filters['sort'] === 'desc') {
                $orderBy = "ORDER BY p.price DESC";
            }
        }

        $query = "SELECT p.*, c.product_type as category_name 
                FROM Product p 
                LEFT JOIN Category c ON p.category_id = c.id 
                $whereClause 
                $orderBy 
                LIMIT :limit OFFSET :offset";

        $stmt = $this->db->prepare($query);

        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }

        $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
        $stmt->execute();

        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // 🔥 Xử lý thumbnail thành full URL
        foreach ($products as &$product) {
            $product['thumbnail'] = $this->processThumbnail($product['thumbnail'], $product['id'] ?? null);
        }

        return $products;
    }

    private function processThumbnail($thumbnail, $productId = null) {
        // Nếu không có thumbnail, tự động quét thư mục ảnh của sản phẩm
        if (empty($thumbnail) && $productId) {
            $images = $this->getProductImagesFromFolder($productId);
            if (!empty($images)) {
                return $images;
            }
        }
        
        // Nếu thumbnail là JSON array
        if (!empty($thumbnail) && $thumbnail[0] === '[') {
            $images = json_decode($thumbnail, true);
            return array_map(function ($img) use ($productId) {
                return $this->normalizeImagePath($img, $productId);
            }, $images);
        }
        
        // Nếu thumbnail là single string
        if (!empty($thumbnail)) {
            return [$this->normalizeImagePath($thumbnail, $productId)];
        }
        
        // Default image - nếu không có gì, tự động quét thư mục
        if ($productId) {
            $images = $this->getProductImagesFromFolder($productId);
            if (!empty($images)) {
                return $images;
            }
        }
        
        return [$this->getDefaultImage()];
    }

    private function getProductImagesFromFolder($productId) {
        // Sử dụng ID trực tiếp vì đã được sắp xếp lại
        $product_dir = "public/images/products/$productId";
        $images = [];
        $base_url = $this->getBaseUrl();

        if (is_dir($product_dir)) {
            return $this->scanDirectoryForImages($product_dir, $productId, $base_url);
        }

        return $images;
    }

    private function scanDirectoryForImages($directory, $folderId, $base_url) {
        $images = [];
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        $files = scandir($directory);

        foreach ($files as $file) {
            if ($file === '.' || $file === '..') continue;
            
            $extension = strtolower(pathinfo($file, PATHINFO_EXTENSION));
            if (in_array($extension, $allowedExtensions)) {
                $images[] = "$base_url/api/images/products/$folderId/$file";
            }
        }

        return $images;
    }

    private function findImageFolderByProductName($productId) {
        // Lấy thông tin sản phẩm
        $query = "SELECT product_name FROM Product WHERE id = :id";
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':id', $productId);
        $stmt->execute();
        $product = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$product) return null;
        
        $productName = strtolower($product['product_name']);
        
        // Mapping rules dựa trên tên sản phẩm và tên file thực tế
        $mappings = [
            // Samsung (dựa trên file names thực tế)
            's25 ultra'        => '1',
    's25+'             => '2',
    'z flip6'          => '3',
    'a56 5g'           => '4',
    'a26 5g'           => '5',

    // 6 → 10: iPhone
    'iphone 16 pro max' => '6',
    'iphone 16 pro'     => '7',
    'iphone 16 plus'    => '8',
    'iphone 15 pro max' => '9',
    'iphone 15'         => '10',

    // 11 → 15: Xiaomi flagship
    'xiaomi 15 ultra'   => '11',
    'xiaomi 15 pro'     => '12',
    'xiaomi 14t pro'    => '13',
    'redmi note 14 pro' => '14',
    'redmi note 14'     => '15',

    // 16 → 20: Realme phones
    'realme gt 6 pro'   => '16',
    'realme gt neo 6'   => '17',
    'realme 13 pro+'    => '18',
    'realme 12+'        => '19',
    'realme c67'        => '20',

    // 21 → 25: Samsung Watches
    'watch 8'           => '21',
    'watch 8 classic'   => '22',
    'watch ultra'       => '23',
    'watch 7'           => '24',
    'watch fe'          => '25',

    // 26 → 30: Apple Watch
    'watch series 9'    => '26',
    'watch series 10'   => '27',
    'watch ultra 2'     => '28',
    'watch se'          => '29',

    // 30 → 34: Xiaomi Watch
    'redmi watch 5 lite'   => '30',
    'redmi watch 5 active' => '31',
    'watch s4 sport'       => '32',
    'watch 2 pro'          => '33',
    'watch s1 active'      => '34',

    // 35 → 39: Realme Watch
    'realme watch 3 pro'   => '35',
    'realme band 3'        => '36',
    'realme watch 3'       => '37',
    'watch s100'           => '38',
    'watch 2 pro'          => '39',

    // 40 → 44: Laptop
    'macbook air m2'       => '40',
    'macbook pro 14 m3'    => '41',
    'dell xps 13 plus'     => '42',
    'hp spectre x360'      => '43',
    'thinkpad x1 carbon'   => '44',

    // 45 → 49: Gaming Laptop / Tablet
    'rog strix'            => '45',
    'ipad pro 12.9'        => '46',
    'ipad air 5'           => '47',
    'galaxy tab s9'        => '48',
    'matepad 11'           => '49',
    'xiaomi pad 6'         => '50',
    'lenovo tab p11'       => '51',

    // 52 → 56: Phụ kiện
    'ốp lưng iphone'       => '52',
    'sạc nhanh anker'      => '53',
    'pin dự phòng baseus'  => '54',
    'tai nghe xiaomi'      => '55',
    'cáp type-c'           => '56',
    'kính cường lực'       => '57',

    // 58 → 62: Gear
    'chuột logitech mx'    => '58',
    'keychron'             => '59',
    'balo asus'            => '60',
    'cooler master'        => '61',
    'samsung t7'           => '62',
    'ugreen hub'           => '63',

    // 64 → 68: Âm thanh
    'sony wh-1000xm5'      => '64',
    'airpods pro'          => '65',
    'jbl charge'           => '66',
    'razer blackshark'     => '67',
    'bose soundlink flex'  => '68',
    'sennheiser momentum'  => '69',

    // 70 → 74: Smartwatch khác
    'garmin forerunner'    => '70',
    'amazfit gtr 4'        => '71', // huawei-watch-gt4.jpg
            
        ];
        
        // Tìm mapping phù hợp
        foreach ($mappings as $keyword => $folderId) {
            if (strpos($productName, $keyword) !== false) {
                return $folderId;
            }
        }
        
        // Backup: Thử tìm theo từ khóa quan trọng (chính xác hơn)
        $keywords = [
            's25 ultra'        => '1',
    's25+'             => '2',
    'z flip6'          => '3',
    'a56 5g'           => '4',
    'a26 5g'           => '5',

    // 6 → 10: iPhone
    'iphone 16 pro max' => '6',
    'iphone 16 pro'     => '7',
    'iphone 16 plus'    => '8',
    'iphone 15 pro max' => '9',
    'iphone 15'         => '10',

    // 11 → 15: Xiaomi flagship
    'xiaomi 15 ultra'   => '11',
    'xiaomi 15 pro'     => '12',
    'xiaomi 14t pro'    => '13',
    'redmi note 14 pro' => '14',
    'redmi note 14'     => '15',

    // 16 → 20: Realme phones
    'realme gt 6 pro'   => '16',
    'realme gt neo 6'   => '17',
    'realme 13 pro+'    => '18',
    'realme 12+'        => '19',
    'realme c67'        => '20',

    // 21 → 25: Samsung Watches
    'watch 8'           => '21',
    'watch 8 classic'   => '22',
    'watch ultra'       => '23',
    'watch 7'           => '24',
    'watch fe'          => '25',

    // 26 → 30: Apple Watch
    'watch series 9'    => '26',
    'watch series 10'   => '27',
    'watch ultra 2'     => '28',
    'watch se'          => '29',

    // 30 → 34: Xiaomi Watch
    'redmi watch 5 lite'   => '30',
    'redmi watch 5 active' => '31',
    'watch s4 sport'       => '32',
    'watch 2 pro'          => '33',
    'watch s1 active'      => '34',

    // 35 → 39: Realme Watch
    'realme watch 3 pro'   => '35',
    'realme band 3'        => '36',
    'realme watch 3'       => '37',
    'watch s100'           => '38',
    'watch 2 pro'          => '39',

    // 40 → 44: Laptop
    'macbook air m2'       => '40',
    'macbook pro 14 m3'    => '41',
    'dell xps 13 plus'     => '42',
    'hp spectre x360'      => '43',
    'thinkpad x1 carbon'   => '44',

    // 45 → 49: Gaming Laptop / Tablet
    'rog strix'            => '45',
    'ipad pro 12.9'        => '46',
    'ipad air 5'           => '47',
    'galaxy tab s9'        => '48',
    'matepad 11'           => '49',
    'xiaomi pad 6'         => '50',
    'lenovo tab p11'       => '51',

    // 52 → 56: Phụ kiện
    'ốp lưng iphone'       => '52',
    'sạc nhanh anker'      => '53',
    'pin dự phòng baseus'  => '54',
    'tai nghe xiaomi'      => '55',
    'cáp type-c'           => '56',
    'kính cường lực'       => '57',

    // 58 → 62: Gear
    'chuột logitech mx'    => '58',
    'keychron'             => '59',
    'balo asus'            => '60',
    'cooler master'        => '61',
    'samsung t7'           => '62',
    'ugreen hub'           => '63',

    // 64 → 68: Âm thanh
    'sony wh-1000xm5'      => '64',
    'airpods pro'          => '65',
    'jbl charge'           => '66',
    'razer blackshark'     => '67',
    'bose soundlink flex'  => '68',
    'sennheiser momentum'  => '69',

    // 70 → 74: Smartwatch khác
    'garmin forerunner'    => '70',
    'amazfit gtr 4'        => '71',
        ];
        
        foreach ($keywords as $keyword => $folderId) {
            if (strpos($productName, $keyword) !== false) {
                return $folderId;
            }
        }
        
        return null;
    }

    private function getBaseUrl() {
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'];
        $script_name = str_replace('\\', '/', $_SERVER['SCRIPT_NAME']);
        $base = rtrim(dirname($script_name), '/\\');
        if ($base === '/' || $base === '.') $base = '';
        
        return "{$protocol}://{$host}{$base}";
    }

    private function normalizeImagePath($path, $productId = null) {
        // Nếu rỗng -> trả default
        if (empty($path)) {
            return $this->getDefaultImage();
        }

        // Nếu path đã là URL đầy đủ
        if (preg_match('#^https?://#i', $path)) {
            return $path;
        }

        // Sử dụng productId trực tiếp vì ảnh đã được sắp xếp theo ID
        if (!empty($productId)) {
            // Nếu path chứa thư mục -> lấy tên file cuối
            if (strpos($path, '/') !== false) {
                $path = basename($path);
            }
            
            $base_url = $this->getBaseUrl();
            return "{$base_url}/api/images/products/{$productId}/{$path}";
        }

        // Không có productId thì trả về default
        return $this->getDefaultImage();
    }

    private function findActualImageFolder($productId, $filename = null) {
        // Thử tìm theo ID trực tiếp trước
        $product_dir = "public/images/products/$productId";
        if (is_dir($product_dir)) {
            if (!$filename || file_exists("$product_dir/$filename")) {
                return $productId;
            }
        }

        // Nếu không có, thử mapping theo tên
        $mappedId = $this->findImageFolderByProductName($productId);
        if ($mappedId) {
            $mapped_dir = "public/images/products/$mappedId";
            if (is_dir($mapped_dir)) {
                if (!$filename || file_exists("$mapped_dir/$filename")) {
                    return $mappedId;
                }
            }
        }

        // Fallback về productId gốc
        return $productId;
    }

   private function getFullUrl($path) {
    // Nếu rỗng -> trả default
    if (empty($path)) {
        return $this->getDefaultImage();
    }

    // Nếu path đã là URL đầy đủ
    if (preg_match('#^https?://#i', $path)) {
        return $path;
    }

    // Protocol + host
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST']; // ví dụ: localhost hoặc localhost:8080

    // Lấy base path (thư mục chứa index.php), ví dụ "/ecommercee"
    $scriptName = str_replace('\\','/', $_SERVER['SCRIPT_NAME']); // e.g. /ecommercee/index.php
    $base = rtrim(dirname($scriptName), '/\\');
    if ($base === '/' || $base === '.') $base = '';

    // Bỏ dấu "/" thừa ở đầu path
    $path = ltrim($path, '/');

    return "{$protocol}://{$host}{$base}/{$path}";
}

    
    private function getDefaultImage() {
        $base_url = $this->getBaseUrl();
        return "{$base_url}/api/images/products/default/default-product.jpg";
    }
    
    public function updateProductThumbnail($product_id, $image_paths) {
        // Nếu là array, lưu dưới dạng JSON
        if (is_array($image_paths)) {
            $thumbnail = json_encode($image_paths);
        } else {
            $thumbnail = $image_paths;
        }
        
        $query = "UPDATE Product SET thumbnail = :thumbnail WHERE id = :id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':id', $product_id);
        $stmt->bindParam(':thumbnail', $thumbnail);
        
        return $stmt->execute();
    }
    
    public function getProductById($id) {
    $query = "SELECT p.*, c.product_type as category_name 
              FROM Product p 
              LEFT JOIN Category c ON p.category_id = c.id 
              WHERE p.id = :id AND p.is_active = TRUE";

    $stmt = $this->db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();

    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($product) {
        $product['thumbnail'] = $this->processThumbnail($product['thumbnail'], $product['id'] ?? $id);
    }

    return $product;
}

    
    public function createProduct($data) {
        $query = "INSERT INTO Product (category_id, product_name, product_type, price, thumbnail, description, stock_quantity) 
                  VALUES (:category_id, :product_name, :product_type, :price, :thumbnail, :description, :stock_quantity)";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':category_id', $data['category_id']);
        $stmt->bindParam(':product_name', $data['product_name']);
        $stmt->bindParam(':product_type', $data['product_type']);
        $stmt->bindParam(':price', $data['price']);
        $stmt->bindParam(':thumbnail', $data['thumbnail']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':stock_quantity', $data['stock_quantity']);
        
        return $stmt->execute();
    }
    
    public function updateProduct($id, $data) {
        $query = "UPDATE Product SET category_id = :category_id, product_name = :product_name, 
                  product_type = :product_type, price = :price, thumbnail = :thumbnail, 
                  description = :description, stock_quantity = :stock_quantity, 
                  updated_at = CURRENT_TIMESTAMP 
                  WHERE id = :id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':category_id', $data['category_id']);
        $stmt->bindParam(':product_name', $data['product_name']);
        $stmt->bindParam(':product_type', $data['product_type']);
        $stmt->bindParam(':price', $data['price']);
        $stmt->bindParam(':thumbnail', $data['thumbnail']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':stock_quantity', $data['stock_quantity']);
        
        return $stmt->execute();
    }
    
    public function deleteProduct($id) {
        $query = "UPDATE Product SET is_active = FALSE WHERE id = :id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':id', $id);
        
        return $stmt->execute();
    }
    
    public function updateStock($id, $quantity) {
        $query = "UPDATE Product SET stock_quantity = stock_quantity - :quantity 
                  WHERE id = :id AND stock_quantity >= :quantity";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':quantity', $quantity);
        
        return $stmt->execute();
    }
    public function searchProducts($keyword, $limit = 20, $categoryId = null, $sort = "")
    {
        try {
            // Tách keyword thành nhiều từ
            $keywords = preg_split('/\s+/', trim($keyword));
            if (!$keywords || count($keywords) === 0) {
                return [];
            }

            $conditions = [];
            $params = [];

            // Với mỗi từ khoá, tạo điều kiện LIKE
            foreach ($keywords as $i => $word) {
                $param = ":kw$i";
                $conditions[] = "(p.product_name LIKE $param 
                                OR p.description LIKE $param 
                                OR p.brand LIKE $param 
                                OR c.product_type LIKE $param)";
                $params[$param] = "%" . $word . "%";
            }

            // Ghép các điều kiện bằng AND (tất cả từ phải match)
            $whereClause = implode(" AND ", $conditions);

            $sql = "
                SELECT p.*, c.product_type as category_name
                FROM Product p
                LEFT JOIN Category c ON p.category_id = c.id
                WHERE p.is_active = TRUE
                AND $whereClause
            ";

            // ✅ Nếu có lọc theo danh mục
            if ($categoryId) {
                $sql .= " AND p.category_id = :category_id";
                $params[":category_id"] = $categoryId;
            }

            // ✅ Sắp xếp
            if ($sort === "asc") {
                $sql .= " ORDER BY p.price ASC";
            } elseif ($sort === "desc") {
                $sql .= " ORDER BY p.price DESC";
            } else {
                $sql .= " ORDER BY p.created_at DESC"; // mặc định: mới nhất
            }

            $sql .= " LIMIT :limit";

            $stmt = $this->db->prepare($sql);

            // Bind các param keyword
            foreach ($params as $param => $value) {
                $stmt->bindValue($param, $value, PDO::PARAM_STR);
            }

            // Nếu có category_id thì bind kiểu INT
            if ($categoryId) {
                $stmt->bindValue(":category_id", (int)$categoryId, PDO::PARAM_INT);
            }

            // Bind limit
            $stmt->bindValue(":limit", (int) $limit, PDO::PARAM_INT);

            $stmt->execute();
            $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // ✅ Xử lý thumbnail bằng function có sẵn
            foreach ($products as &$product) {
                $product['thumbnail'] = $this->processThumbnail($product['thumbnail'], $product['id'] ?? null);
            }

            return $products;
        } catch (PDOException $e) {
            error_log("Search products failed: " . $e->getMessage());
            return [];
        }
    }



    public function getRecommendedProducts($excludeId = null, $limit = 8) {
        try {
            $whereClause = "WHERE p.is_active = TRUE AND p.stock_quantity > 0";
            $params = [];
            
            if ($excludeId) {
                $whereClause .= " AND p.id != :exclude_id";
                $params[':exclude_id'] = $excludeId;
            }
            
            $sql = "SELECT p.*, c.product_type as category_name
                    FROM Product p
                    LEFT JOIN Category c ON p.category_id = c.id
                    $whereClause
                    ORDER BY p.stock_quantity DESC, p.created_at DESC
                    LIMIT :limit";

            $stmt = $this->db->prepare($sql);
            
            foreach ($params as $key => $value) {
                $stmt->bindValue($key, $value);
            }
            
            $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
            $stmt->execute();

            $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Xử lý thumbnail cho sản phẩm gợi ý
            foreach ($products as &$product) {
                $product['thumbnail'] = $this->processThumbnail($product['thumbnail'], $product['id'] ?? null);
            }

            return $products;
        } catch (PDOException $e) {
            return [];
        }
    }

    public function syncAllProductImages() {
        $query = "SELECT id FROM Product WHERE is_active = TRUE";
        $stmt = $this->db->query($query);
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $updated = 0;
        foreach ($products as $product) {
            $images = $this->getProductImagesFromFolder($product['id']);
            if (!empty($images)) {
                // Lưu tên file thay vì URL đầy đủ
                $filenames = [];
                foreach ($images as $url) {
                    $filename = basename(parse_url($url, PHP_URL_PATH));
                    $filenames[] = $filename;
                }
                
                $this->updateProductThumbnail($product['id'], $filenames);
                $updated++;
            }
        }
        
        return $updated;
    }

}