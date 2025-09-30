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

    // Count total records with same filters
    $countQuery = "SELECT COUNT(*) as total 
                   FROM Product p 
                   LEFT JOIN Category c ON p.category_id = c.id 
                   $whereClause";
    
    $countStmt = $this->db->prepare($countQuery);
    foreach ($params as $key => $value) {
        $countStmt->bindValue($key, $value);
    }
    $countStmt->execute();
    $totalRecords = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];

    $query = "SELECT p.*, c.product_type as category_name 
              FROM Product p 
              LEFT JOIN Category c ON p.category_id = c.id 
              $whereClause 
              ORDER BY p.created_at DESC 
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

    return [
        'data' => $products,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $totalRecords,
            'total_pages' => ceil($totalRecords / $limit),
            'has_more' => ($page * $limit) < $totalRecords
        ]
    ];
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
        // Chỉ sử dụng ID trực tiếp - đơn giản và rõ ràng
        $product_dir = "public/images/products/$productId";
        $base_url = $this->getBaseUrl();

        if (is_dir($product_dir)) {
            return $this->scanDirectoryForImages($product_dir, $productId, $base_url);
        }

        return []; // Không có ảnh thì trả về mảng rỗng
    }

    private function scanDirectoryForImages($directory, $folderId, $base_url) {
        $images = [];
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        $files = scandir($directory);

        foreach ($files as $file) {
            if ($file === '.' || $file === '..') continue;
            
            $extension = strtolower(pathinfo($file, PATHINFO_EXTENSION));
            if (in_array($extension, $allowedExtensions)) {
                $images[] = "$base_url/index.php/api/images/products/$folderId/$file";
            }
        }

        return $images;
    }

    // Hàm này đã được loại bỏ để đơn giản hóa code
    // Thay vào đó, chỉ sử dụng ID sản phẩm trực tiếp

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
            return "{$base_url}/index.php/api/images/products/{$productId}/{$path}";
        }

        // Không có productId thì trả về default
        return $this->getDefaultImage();
    }

    // Hàm này đã được loại bỏ - chỉ sử dụng productId trực tiếp

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
        // Trả về empty string thay vì hardcode path
        // Frontend sẽ xử lý fallback image
        return '';
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
    
    public function getLastInsertId() {
        return $this->db->lastInsertId();
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
    public function searchProducts($keyword, $limit = 20) {
        try {
            $sql = "SELECT p.*, c.product_type as category_name
                    FROM Product p
                    LEFT JOIN Category c ON p.category_id = c.id
                    WHERE p.is_active = TRUE
                    AND (p.product_name LIKE :kw OR p.description LIKE :kw)
                    ORDER BY p.created_at DESC
                    LIMIT :limit";

            $stmt = $this->db->prepare($sql); // ✅ đổi từ $this->conn thành $this->db
            $kw = "%" . $keyword . "%";
            $stmt->bindParam(":kw", $kw, PDO::PARAM_STR);
            $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
            $stmt->execute();

            $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // xử lý thumbnail cho kết quả tìm kiếm
            foreach ($products as &$product) {
                $product['thumbnail'] = $this->processThumbnail($product['thumbnail'], $product['id'] ?? null);
            }

            return $products;
        } catch (PDOException $e) {
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