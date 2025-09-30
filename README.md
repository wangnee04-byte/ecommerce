# TechMall E-commerce API

## 📋 Tổng quan

TechMall là một hệ thống e-commerce hoàn chỉnh được xây dựng bằng PHP thuần, cung cấp API RESTful cho việc quản lý cửa hàng trực tuyến với đầy đủ các tính năng hiện đại như xác thực JWT, phân quyền RBAC, thanh toán đa kênh và quản lý sản phẩm thông minh.

## 🚀 Tính năng chính

### 🛡️ Bảo mật & Xác thực
- **JWT Authentication** - Xác thực token an toàn
- **RBAC (Role-Based Access Control)** - Phân quyền theo vai trò
- **Multi-level Admin** - Hệ thống admin phân cấp (Super Admin, Admin, Moderator)
- **Password Security** - Mã hóa password với bcrypt
- **Session Management** - Quản lý phiên đăng nhập

### 🛍️ Quản lý sản phẩm
- **Product Management** - CRUD sản phẩm với hình ảnh
- **Category System** - Phân loại sản phẩm theo danh mục
- **Image Upload** - Upload và quản lý hình ảnh sản phẩm
- **Product Search** - Tìm kiếm và lọc sản phẩm
- **Inventory Tracking** - Theo dõi tồn kho

### 🛒 Hệ thống mua hàng
- **Shopping Cart** - Giỏ hàng thông minh
- **Order Management** - Quản lý đơn hàng toàn diện
- **Order Status** - Theo dõi trạng thái đơn hàng
- **Order History** - Lịch sử mua hàng

### 💳 Thanh toán đa kênh
- **PayPal Integration** - Thanh toán qua PayPal
- **MoMo Payment** - Cổng thanh toán MoMo
- **COD (Cash on Delivery)** - Thanh toán khi nhận hàng
- **Payment Tracking** - Theo dõi giao dịch

### 👥 Quản lý người dùng
- **User Registration** - Đăng ký tài khoản
- **Profile Management** - Quản lý thông tin cá nhân
- **Address Book** - Sổ địa chỉ giao hàng
- **User Roles** - Phân quyền người dùng

### 📊 Admin Dashboard
- **Product Management** - Quản lý sản phẩm
- **User Management** - Quản lý người dùng
- **Order Management** - Quản lý đơn hàng
- **Analytics** - Thống kê và báo cáo
- **Advertisement** - Quản lý quảng cáo

## 🏗️ Kiến trúc hệ thống

```
ecommerce_api/
├── 📁 config/              # Cấu hình hệ thống
│   ├── constants.php       # Hằng số và cấu hình
│   └── database.php        # Cấu hình database
├── 📁 controllers/         # Controllers xử lý logic
│   ├── AuthController.php  # Xác thực & đăng nhập
│   ├── ProductController.php # Quản lý sản phẩm
│   ├── UserController.php  # Quản lý người dùng
│   ├── CartController.php  # Giỏ hàng
│   ├── OrderController.php # Đơn hàng
│   └── PaymentController.php # Thanh toán
├── 📁 models/              # Models xử lý dữ liệu
│   ├── UserModel.php       # Model người dùng
│   ├── ProductModel.php    # Model sản phẩm
│   ├── CartModel.php       # Model giỏ hàng
│   └── OrderModel.php      # Model đơn hàng
├── 📁 middleware/          # Middleware bảo mật
│   ├── AuthMiddleware.php  # Xác thực JWT
│   ├── RBACMiddleware.php  # Phân quyền RBAC
│   └── ValidationMiddleware.php # Validation
├── 📁 utils/               # Utilities & helpers
│   ├── Database.php        # Database connection
│   ├── JWT.php             # JWT handling
│   ├── Response.php        # API response
│   ├── Validator.php       # Data validation
│   └── Logger.php          # Logging system
├── 📁 fe/                  # Frontend files
│   ├── 📁 js/              # JavaScript files
│   └── *.html              # HTML pages
├── 📁 public/images/       # Uploaded images
├── 📁 database/            # Database schema
│   └── ecommercedb.sql     # Database structure
└── index.php              # API entry point
```

## 🛠️ Yêu cầu hệ thống

### Server Requirements
- **PHP**: >= 7.4
- **MySQL/MariaDB**: >= 5.7
- **Apache/Nginx**: Web server
- **Composer**: Dependency management

### PHP Extensions
- `ext-pdo` - Database connectivity
- `ext-json` - JSON handling
- `ext-mbstring` - String functions
- `ext-openssl` - Encryption
- `ext-curl` - HTTP requests

### Dependencies
- **PHPMailer**: ^6.10 - Email sending
- **JWT**: Custom implementation

## 📦 Cài đặt

### 1. Clone Repository
```bash
git clone [repository-url]
cd ecommerce_api
```

### 2. Install Dependencies
```bash
composer install
```

### 3. Database Setup
```sql
-- Tạo database
CREATE DATABASE ecommercedb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Import schema
mysql -u root -p ecommercedb < database/ecommercedb.sql
```

### 4. Configuration
Cập nhật cấu hình trong `config/database.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'ecommercedb');
define('DB_USER', 'your_username');
define('DB_PASS', 'your_password');
```

Cập nhật JWT secret trong `config/constants.php`:
```php
define('JWT_SECRET', 'your-strong-secret-key');
```

### 5. Directory Permissions
```bash
chmod 755 public/images/
chmod 755 public/images/products/
```

### 6. Web Server Setup

#### Apache (.htaccess)
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

#### Nginx
```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

## 🚀 Chạy ứng dụng

### Development Server
```bash
php -S localhost:8000
```

### Production
- Upload files lên web server
- Cấu hình virtual host
- Đảm bảo permissions đúng

## 📚 API Documentation

### Base URL
```
http://localhost:8000/api
```

### Authentication Headers
```javascript
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

### Key Endpoints

#### 🔐 Authentication
```http
POST /api/register          # Đăng ký tài khoản
POST /api/login             # Đăng nhập
POST /api/logout            # Đăng xuất
```

#### 👤 User Management
```http
GET    /api/users           # Danh sách người dùng (Admin)
GET    /api/users/{id}      # Chi tiết người dùng
PUT    /api/users/{id}      # Cập nhật thông tin
DELETE /api/users/{id}      # Xóa người dùng (Admin)
PUT    /api/users/{id}/roles # Cập nhật vai trò (Super Admin)
```

#### 🛍️ Products
```http
GET    /api/products        # Danh sách sản phẩm
GET    /api/products/{id}   # Chi tiết sản phẩm
POST   /api/products        # Tạo sản phẩm (Admin)
PUT    /api/products/{id}   # Cập nhật sản phẩm (Admin)
DELETE /api/products/{id}   # Xóa sản phẩm (Admin)
```

#### 🛒 Cart & Orders
```http
GET    /api/cart            # Xem giỏ hàng
POST   /api/cart/add        # Thêm vào giỏ
PUT    /api/cart/{id}       # Cập nhật số lượng
DELETE /api/cart/{id}       # Xóa khỏi giỏ
POST   /api/orders          # Tạo đơn hàng
GET    /api/orders          # Lịch sử đơn hàng
```

#### 💳 Payments
```http
POST   /api/payments/paypal    # Thanh toán PayPal
POST   /api/payments/momo      # Thanh toán MoMo
POST   /api/payments/cod       # Thanh toán COD
GET    /api/payments/{id}      # Trạng thái thanh toán
```

## 🎭 Hệ thống phân quyền

### User Roles
- **Customer (ID: 2)** - Khách hàng thường
- **Moderator (ID: 3)** - Kiểm duyệt viên
- **Admin (ID: 4)** - Quản trị viên
- **Super Admin (ID: 1)** - Quản trị cấp cao

### Permissions Matrix
| Action | Customer | Moderator | Admin | Super Admin |
|--------|----------|-----------|-------|-------------|
| View Products | ✅ | ✅ | ✅ | ✅ |
| Manage Products | ❌ | ❌ | ✅ | ✅ |
| View Users | ❌ | ✅ | ✅ | ✅ |
| Manage Users | ❌ | ❌ | ✅ | ✅ |
| Manage Roles | ❌ | ❌ | ❌ | ✅ |
| System Config | ❌ | ❌ | ❌ | ✅ |

## 🔒 Bảo mật

### Security Features
- **JWT Token Expiration** - Token tự động hết hạn
- **Password Hashing** - Bcrypt encryption
- **SQL Injection Prevention** - Prepared statements
- **XSS Protection** - Input sanitization
- **CORS Configuration** - Cross-origin security
- **Rate Limiting** - Chống spam request
- **Role-based Access** - Phân quyền chặt chẽ

### Security Rules
- Super Admin không thể tự xóa/sửa quyền của mình
- Hệ thống phải có ít nhất 1 Super Admin
- Chỉ Super Admin mới có thể sửa quyền Super Admin khác
- Token JWT có thời gian sống giới hạn

## 🧪 Testing

### Manual Testing
1. Test authentication flow
2. Test CRUD operations
3. Test role-based permissions
4. Test payment flows
5. Test image uploads

### API Testing Tools
- **Postman** - API testing
- **Insomnia** - REST client
- **curl** - Command line testing

## 📝 Database Schema

### Core Tables
- `users` - Thông tin người dùng
- `user_roles` - Phân quyền người dùng
- `products` - Sản phẩm
- `categories` - Danh mục sản phẩm
- `cart` & `cart_items` - Giỏ hàng
- `orders` & `order_items` - Đơn hàng
- `payments` - Thanh toán
- `advertisement` - Quảng cáo

### Key Relationships
```sql
users 1:N user_roles N:1 roles
users 1:N cart 1:N cart_items N:1 products
users 1:N orders 1:N order_items N:1 products
orders 1:1 payments
products N:1 categories
```

## 🚀 Deployment

### Production Checklist
- [ ] Update JWT secret key
- [ ] Configure database credentials
- [ ] Set up SSL/HTTPS
- [ ] Configure email settings
- [ ] Set proper file permissions
- [ ] Enable error logging
- [ ] Configure backup strategy
- [ ] Set up monitoring

### Environment Variables
```bash
# Database
DB_HOST=localhost
DB_NAME=ecommercedb
DB_USER=username
DB_PASS=password

# JWT
JWT_SECRET=your-production-secret

# Email
SMTP_HOST=smtp.gmail.com
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
```

## 🤝 Contributing

### Development Workflow
1. Fork repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

### Code Standards
- PSR-4 autoloading
- Consistent naming conventions
- Proper error handling
- Security best practices
- Clean code principles

## 📞 Support

### Documentation
- API endpoints documented in code
- Database schema in `/database`
- Frontend examples in `/fe`

### Issues
- Report bugs via GitHub issues
- Feature requests welcome
- Security issues: private contact

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎯 Roadmap

### Upcoming Features
- [ ] Product reviews & ratings
- [ ] Wishlist functionality
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Mobile app API
- [ ] Third-party integrations
- [ ] Performance optimizations
- [ ] Caching layer

### Version History
- **v1.0** - Core e-commerce functionality
- **v1.1** - Enhanced security & RBAC
- **v1.2** - Payment integrations
- **v1.3** - Admin dashboard improvements

---

**Phát triển bởi**: TechMall Team  
**Cập nhật lần cuối**: September 2025  
**Version**: 1.3.0