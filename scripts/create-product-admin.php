<?php
require_once '../utils/Database.php';

try {
    $db = (new Database())->getConnection();
    
    // Tạo product admin
    $email = 'product.admin@techmall.com';
    $password = password_hash('product123456', PASSWORD_DEFAULT);
    
    // Kiểm tra xem user đã tồn tại chưa
    $check = $db->prepare("SELECT id FROM users WHERE email = :email");
    $check->execute([':email' => $email]);
    
    if ($check->rowCount() > 0) {
        echo "❌ Product admin user already exists: $email\n";
        exit;
    }
    
    // Tạo user product admin
    $stmt = $db->prepare("INSERT INTO users (full_name, email, password, phone, address, is_active) 
                          VALUES (:name, :email, :password, :phone, :address, 1)");
    $stmt->execute([
        ':name' => 'Product Administrator',
        ':email' => $email,
        ':password' => $password,
        ':phone' => '0123456789',
        ':address' => 'TechMall Product Dept'
    ]);
    
    $user_id = $db->lastInsertId();
    
    // Gán role product_admin (id = 4)
    $stmt = $db->prepare("INSERT INTO user_role (user_id, role_id) VALUES (:user_id, 4)");
    $stmt->execute([':user_id' => $user_id]);
    
    echo "✅ Created product admin user:\n";
    echo "   Email: $email\n";
    echo "   Password: product123456\n";
    echo "   User ID: $user_id\n";
    echo "   Role: product_admin (ID: 4)\n\n";
    
    echo "🔐 Product Admin Test Account:\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "📧 Email: product.admin@techmall.com\n";
    echo "🔑 Password: product123456\n";
    echo "🎯 Permissions: Chỉ quản lý sản phẩm\n";
    echo "❌ Không thể truy cập: Quản lý user\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>