-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th9 26, 2025 lúc 04:12 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `ecommercedb`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `advertisement`
--

CREATE TABLE `advertisement` (
  `id` int(11) NOT NULL,
  `company_info` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cart`
--

CREATE TABLE `cart` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `cart`
--

INSERT INTO `cart` (`id`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 1, '2025-09-17 10:52:14', '2025-09-17 10:52:14'),
(2, 3, '2025-09-17 12:14:48', '2025-09-17 12:14:48'),
(3, 10, '2025-09-20 14:57:48', '2025-09-20 14:57:48');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cart_items`
--

CREATE TABLE `cart_items` (
  `id` int(11) NOT NULL,
  `cart_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `quantity` int(11) NOT NULL CHECK (`quantity` > 0),
  `added_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `category`
--

CREATE TABLE `category` (
  `id` int(11) NOT NULL,
  `product_type` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `category`
--

TRUNCATE TABLE category;

INSERT INTO category (id, product_type, description, is_active) VALUES
(1, 'Điện thoại', 'Các loại điện thoại smartphone', 1),
(2, 'Laptop', 'Máy tính xách tay', 1),
(3, 'Tablet', 'Máy tính bảng', 1),
(4, 'Phụ kiện điện thoại', 'Ốp lưng, sạc, pin dự phòng...', 1),
(5, 'Phụ kiện laptop', 'Chuột, bàn phím, balo...', 1),
(6, 'Âm thanh', 'Tai nghe, loa bluetooth...', 1),
(7, 'Đồng hồ thông minh', 'Các loại smartwatch', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dim_date`
--

CREATE TABLE `dim_date` (
  `date_id` int(11) NOT NULL,
  `full_date` date DEFAULT NULL,
  `day` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `quarter` int(11) DEFAULT NULL,
  `year` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dim_product`
--

CREATE TABLE `dim_product` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `fact_sales`
--

CREATE TABLE `fact_sales` (
  `id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `date_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `total_amount` decimal(18,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `attempts` int(11) DEFAULT 0,
  `last_attempt` timestamp NOT NULL DEFAULT current_timestamp(),
  `locked_until` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `login_attempts`
--

INSERT INTO `login_attempts` (`id`, `user_id`, `attempts`, `last_attempt`, `locked_until`) VALUES
(1, 3, 0, '2025-09-26 14:08:52', NULL),
(2, 1, 0, '2025-09-26 11:13:31', NULL),
(3, 7, 0, '2025-09-12 16:52:37', NULL),
(4, 10, 0, '2025-09-20 14:57:42', NULL),
(5, 11, 0, '2025-09-26 10:22:05', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `fullname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `note` text DEFAULT NULL,
  `status` enum('pending','confirmed','shipped','delivered','cancel_request','cancelled') DEFAULT 'pending',
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `total` decimal(18,2) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `payment_method` enum('cod','momo','paypal') DEFAULT 'cod',
  `paypal_order_id` varchar(255) DEFAULT NULL,
  `payment_status` enum('pending','paid','failed') DEFAULT 'pending',
  `momo_transaction_id` varchar(255) DEFAULT NULL,
  `paypal_transaction_id` varchar(255) DEFAULT NULL,
  `paypal_payer_email` varchar(255) DEFAULT NULL,
  `payment_date` timestamp NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- Cấu trúc bảng cho bảng `order_details`
--

CREATE TABLE `order_details` (
  `id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `price` decimal(18,2) NOT NULL,
  `quantity` int(11) NOT NULL,
  `total` decimal(18,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


--
-- Cấu trúc bảng cho bảng `payments`
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `payment_method` enum('cod','momo','paypal') DEFAULT NULL,
  `amount` decimal(18,2) NOT NULL,
  `status` enum('pending','paid','failed') DEFAULT 'pending',
  `transaction_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- Cấu trúc bảng cho bảng `permission`
--

CREATE TABLE `permission` (
  `id` int(11) NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `permission_group` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `permission`
--

INSERT INTO `permission` (`id`, `permission_name`, `description`, `permission_group`, `created_at`) VALUES
(1, 'user.create', 'Tạo người dùng mới', 'user_management', '2025-09-09 15:06:45'),
(2, 'user.read', 'Xem thông tin người dùng', 'user_management', '2025-09-09 15:06:45'),
(3, 'user.update', 'Cập nhật thông tin người dùng', 'user_management', '2025-09-09 15:06:45'),
(4, 'user.delete', 'Xóa người dùng', 'user_management', '2025-09-09 15:06:45'),
(5, 'user.role.manage', 'Quản lý vai trò người dùng', 'user_management', '2025-09-09 15:06:45'),
(6, 'product.create', 'Tạo sản phẩm mới', 'product_management', '2025-09-09 15:06:45'),
(7, 'product.read', 'Xem thông tin sản phẩm', 'product_management', '2025-09-09 15:06:45'),
(8, 'product.update', 'Cập nhật thông tin sản phẩm', 'product_management', '2025-09-09 15:06:45'),
(9, 'product.delete', 'Xóa sản phẩm', 'product_management', '2025-09-09 15:06:45'),
(10, 'product.inventory.manage', 'Quản lý tồn kho sản phẩm', 'product_management', '2025-09-09 15:06:45'),
(11, 'category.create', 'Tạo danh mục mới', 'category_management', '2025-09-09 15:06:45'),
(12, 'category.read', 'Xem danh mục', 'category_management', '2025-09-09 15:06:45'),
(13, 'category.update', 'Cập nhật danh mục', 'category_management', '2025-09-09 15:06:45'),
(14, 'category.delete', 'Xóa danh mục', 'category_management', '2025-09-09 15:06:45'),
(15, 'order.create', 'Tạo đơn hàng', 'order_management', '2025-09-09 15:06:45'),
(16, 'order.read', 'Xem đơn hàng', 'order_management', '2025-09-09 15:06:45'),
(17, 'order.update', 'Cập nhật đơn hàng', 'order_management', '2025-09-09 15:06:45'),
(18, 'order.delete', 'Xóa đơn hàng', 'order_management', '2025-09-09 15:06:45'),
(19, 'order.status.update', 'Cập nhật trạng thái đơn hàng', 'order_management', '2025-09-09 15:06:45'),
(20, 'cart.manage', 'Quản lý giỏ hàng', 'cart_management', '2025-09-09 15:06:45'),
(21, 'advertisement.create', 'Tạo quảng cáo', 'advertisement_management', '2025-09-09 15:06:45'),
(22, 'advertisement.read', 'Xem quảng cáo', 'advertisement_management', '2025-09-09 15:06:45'),
(23, 'advertisement.update', 'Cập nhật quảng cáo', 'advertisement_management', '2025-09-09 15:06:45'),
(24, 'advertisement.delete', 'Xóa quảng cáo', 'advertisement_management', '2025-09-09 15:06:45'),
(25, 'sales.view', 'Xem báo cáo doanh thu', 'report_management', '2025-09-09 15:06:45'),
(26, 'dashboard.view', 'Xem dashboard thống kê', 'report_management', '2025-09-09 15:06:45');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product`
--

CREATE TABLE `product` (
  `id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `product_name` varchar(100) NOT NULL,
  `product_type` varchar(100) DEFAULT NULL,
  `price` decimal(18,2) NOT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `stock_quantity` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `product`
--

INSERT INTO `product` (`id`, `category_id`, `product_name`, `product_type`, `price`, `thumbnail`, `description`, `stock_quantity`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Samsung Galaxy S25 Ultra', 'Điện thoại', 33390000.00, 's25-ultra.webp', 'Flagship Samsung 2025: Snapdragon 8 Elite, RAM 12GB, bộ nhớ 256GB, pin 5000mAh, camera 200MP', 120, 1, '2025-09-09 15:10:34', '2025-09-17 10:22:55'),
(2, 1, 'Samsung Galaxy S25+', 'Điện thoại', 27990000.00, '', 'Màn hình Dynamic AMOLED 6.7\", RAM 8GB, bộ nhớ 256GB, hỗ trợ 5G, camera chính 50MP', 135, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(3, 1, 'Samsung Galaxy Z Flip6', 'Điện thoại', 25990000.00, '', 'Điện thoại màn hình gập 6.7\", RAM 8GB, bộ nhớ 256GB, camera kép 50MP', 145, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(4, 1, 'Samsung Galaxy A56 5G', 'Điện thoại', 10990000.00, '', 'Điện thoại tầm trung với màn hình 6.6\", Snapdragon 7s Gen 2, camera 50MP, pin 5000mAh', 138, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(5, 1, 'Samsung Galaxy A26 5G', 'Điện thoại', 7990000.00, '', 'Màn hình 6.5\", chip Exynos 1330, RAM 6GB, bộ nhớ 128GB, camera kép 50MP, pin 5000mAh', 142, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(6, 1, 'iPhone 16 Pro Max', 'Điện thoại', 34990000.00, '', 'iPhone cao cấp 2025: chip A18 Pro, màn hình 6.9\", RAM 8GB, camera 48MP, pin 5000mAh', 140, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(7, 1, 'iPhone 16 Pro', 'Điện thoại', 30990000.00, '', 'Màn hình 6.3\", chip A18 Pro, RAM 8GB, bộ nhớ 256GB, hỗ trợ 5G', 133, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(8, 1, 'iPhone 16 Plus', 'Điện thoại', 26990000.00, '', 'Chip A17 Bionic, RAM 6GB, camera kép 48MP, pin 4900mAh', 115, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(9, 1, 'iPhone 15 Pro Max', 'Điện thoại', 28990000.00, '', 'Màn hình 6.7\", RAM 8GB, bộ nhớ 256GB, camera tele 5x zoom', 148, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(10, 1, 'iPhone 15', 'Điện thoại', 18990000.00, '', 'Màn hình 6.1\", RAM 6GB, bộ nhớ 128GB, hỗ trợ 5G, camera kép 48MP', 125, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(11, 1, 'Xiaomi 15 Ultra', 'Điện thoại', 24990000.00, '', 'Màn hình AMOLED 6.7\", RAM 16GB, pin 5000mAh, sạc nhanh 120W, camera 200MP', 121, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(12, 1, 'Xiaomi 15 Pro', 'Điện thoại', 20990000.00, '', 'Flagship Xiaomi với màn hình 6.73\", RAM 12GB, pin 4880mAh, sạc nhanh 120W', 137, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(13, 1, 'Xiaomi 14T Pro', 'Điện thoại', 15990000.00, '', 'Màn hình AMOLED 6.7\", RAM 12GB, pin 5000mAh, sạc nhanh 120W', 149, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(14, 1, 'Xiaomi Redmi Note 14 Pro+', 'Điện thoại', 9990000.00, '', 'Màn hình AMOLED 6.67\", Dimensity 8200 Ultra, RAM 8GB, pin 5000mAh', 118, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(15, 1, 'Xiaomi Redmi Note 14', 'Điện thoại', 6990000.00, '', 'Màn hình AMOLED 6.6\", Snapdragon 7s Gen 2, RAM 6GB, camera 100MP', 132, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(16, 1, 'Realme GT 6 Pro', 'Điện thoại', 18990000.00, '', 'Flagship Realme với màn hình 6.78\", RAM 16GB, pin 5500mAh, sạc nhanh 120W', 127, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(17, 1, 'Realme GT Neo 6', 'Điện thoại', 13990000.00, '', 'Màn hình AMOLED 6.7\", RAM 12GB, pin 5000mAh, camera 50MP', 146, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(18, 1, 'Realme 13 Pro+', 'Điện thoại', 10990000.00, '', 'Màn hình AMOLED 6.7\", Snapdragon 7s Gen 3, RAM 8GB, pin 5000mAh', 141, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(19, 1, 'Realme 12+', 'Điện thoại', 7990000.00, '', 'Chip Dimensity 7050, RAM 8GB, bộ nhớ 256GB, camera 50MP OIS', 119, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(20, 1, 'Realme C67', 'Điện thoại', 5990000.00, '', 'Màn hình AMOLED 6.6\", RAM 6GB, camera 108MP, pin 5000mAh, sạc 33W', 134, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(21, 7, 'Samsung Galaxy Watch 8', 'Đồng hồ thông minh', 10448155.00, '', 'Galaxy Watch 8: màn AMOLED 1.6″, lưu trữ 16 GB, pin 410mAh, GPS, chống nước 5ATM', 129, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(22, 7, 'Samsung Galaxy Watch 8 Classic', 'Đồng hồ thông minh', 14599115.00, '', 'Màn 1.5″ AMOLED, viền xoay bằng thép không gỉ, pin 300mAh, LTE tùy chọn', 149, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(23, 7, 'Samsung Galaxy Watch Ultra', 'Đồng hồ thông minh', 15306665.00, '', 'Màn 1.9″ Super AMOLED, khung titanium, pin lớn 599mAh, GPS độ chính xác cao', 107, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(24, 7, 'Samsung Galaxy Watch 7', 'Đồng hồ thông minh', 6132100.00, '', 'Thiết kế mỏng nhẹ, GPS, theo dõi giấc ngủ, pin dùng cả ngày', 143, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(25, 7, 'Samsung Galaxy Watch FE', 'Đồng hồ thông minh', 4717000.00, '', 'Màn AMOLED, GPS, thiết kế đơn giản, pin 300mAh, nhẹ và giá mềm', 140, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(26, 7, 'Apple Watch Series 9 (Nhôm)', 'Đồng hồ thông minh', 10499000.00, '', 'Siri chạy trên thiết bị, chip S9 SiP, màn Retina LTPO OLED luôn bật, chống nước 50 m', 120, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(27, 7, 'Apple Watch Series 9 (Thép)', 'Đồng hồ thông minh', 18990000.00, '', 'Vỏ thép không gỉ, màn sáng 2000 nits, nút Action, phần mềm watchOS 10', 131, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(28, 7, 'Apple Watch Series 10', 'Đồng hồ thông minh', 10799000.00, '', 'Phiên bản GPS + Cellular, cảm biến ECG, màn Retina OLED luôn bật, Titan bền', 143, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(29, 7, 'Apple Watch Ultra 2', 'Đồng hồ thông minh', 18990000.00, '', 'Pin 36 giờ, tính năng thể thao chuyên sâu, nút Tác Vụ tùy chỉnh, chống nước 100 m', 123, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(30, 7, 'Apple Watch SE (thế hệ 2)', 'Đồng hồ thông minh', 6990000.00, '', 'Chip S8 giống Watch 8, GPS, theo dõi sức khỏe, giá dễ chịu', 137, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(31, 7, 'Xiaomi Redmi Watch 5 Lite', 'Đồng hồ thông minh', 1270000.00, '', 'Màn 1.55″ TFT, pin dùng 10 ngày, theo dõi nhịp tim & giấc ngủ', 114, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(32, 7, 'Xiaomi Redmi Watch 5 Active', 'Đồng hồ thông minh', 2830500.00, '', 'Màn AMOLED 1.91″, GPS tích hợp, vỏ nhẹ, pin dùng nhiều ngày', 111, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(33, 7, 'Xiaomi Watch S4 Sport', 'Đồng hồ thông minh', 6485875.00, '', 'Màn 1.96″ AMOLED lớn, theo dõi nhịp tim, pin 480mAh, GPS+BT', 112, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(34, 7, 'Xiaomi Watch 2 Pro', 'Đồng hồ thông minh', 6721725.00, '', 'Always-on display, Wi-Fi, GPS chính xác, pin 500mAh', 130, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(35, 7, 'Xiaomi Watch S1 Active', 'Đồng hồ thông minh', 4952850.00, '', 'Màn AMOLED 1.43″, pin 420mAh, vỏ nhẹ, nhiều mặt đồng hồ', 113, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(36, 7, 'Realme Watch 3 Pro', 'Đồng hồ thông minh', 1890000.00, '', 'GPS kép, màn 1.78″, pin dùng 14 ngày, theo dõi thể thao', 126, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(37, 7, 'Realme Band 3', 'Đồng hồ thông minh', 890000.00, '', 'Vòng tay nhỏ gọn, theo dõi nhịp tim, SPO2, pin 12 ngày', 140, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(38, 7, 'Realme Watch 3', 'Đồng hồ thông minh', 1690000.00, '', 'Màn 1.8″ IPS, theo dõi sức khỏe, pin 288mAh dùng 10 ngày', 120, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(39, 7, 'Realme Watch S100', 'Đồng hồ thông minh', 2190000.00, '', 'Khung thép, màn OLED, pin dùng tới 10 ngày, nhiều chế độ tập luyện', 134, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(40, 7, 'Realme Watch 2 Pro', 'Đồng hồ thông minh', 2990000.00, '', 'GPS hai băng tần, màn 1.75″, pin 390mAh, theo dõi nâng cao', 106, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(41, 2, 'MacBook Air M2 2023', 'Laptop', 32990000.00, 'macbook-air-m2.jpg', 'Laptop siêu mỏng nhẹ, chip Apple M2.', 10, 1, '2025-09-23 08:22:20', '2025-09-23 08:22:20'),
(42, 2, 'MacBook Pro 14 M3', 'Laptop', 49990000.00, 'macbook-pro-14-m3.jpg', 'Hiệu năng mạnh mẽ với chip Apple M3.', 8, 1, '2025-09-23 08:22:20', '2025-09-23 08:22:20'),
(43, 2, 'Dell XPS 13 Plus', 'Laptop', 38990000.00, 'dell-xps-13-plus.jpg', 'Ultrabook cao cấp, màn OLED.', 12, 1, '2025-09-23 08:22:20', '2025-09-23 08:22:20'),
(44, 2, 'Asus ROG Strix G16', 'Laptop', 44990000.00, 'asus-rog-strix-g16.jpg', 'Laptop gaming, RTX 4070, màn 240Hz.', 7, 1, '2025-09-23 08:22:20', '2025-09-23 08:22:20'),
(45, 3, 'iPad Pro 12.9 2022', 'Tablet', 28990000.00, 'ipad-pro-12-9.jpg', 'Màn hình Liquid Retina XDR, chip M2.', 10, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(46, 3, 'Samsung Galaxy Tab S9', 'Tablet', 19990000.00, 'galaxy-tab-s9.jpg', 'Máy tính bảng AMOLED 120Hz.', 12, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(47, 3, 'Xiaomi Pad 6 Pro', 'Tablet', 999990000.00, '[\"http://localhost/ecommerce_api/public/images/products/47/xiaomi-pad-6-pro.jpg\"]', 'Máy tính bảng cấu hình mạnh.', 20, 1, '2025-09-23 08:23:05', '2025-09-25 19:06:27'),
(48, 3, 'Lenovo Tab P11 Pro', 'Tablet', 11990000.00, 'lenovo-tab-p11-pro.jpg', 'Màn OLED, pin 8600mAh.', 15, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(49, 4, 'Ốp lưng iPhone 15', 'Phụ kiện điện thoại', 299000.00, 'oplung-iphone15.jpg', 'Ốp lưng chống sốc cho iPhone 15.', 50, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(50, 4, 'Sạc nhanh Anker 30W', 'Phụ kiện điện thoại', 690000.00, 'sac-nhanh-anker.jpg', 'Củ sạc nhanh Anker PowerPort, công suất 30W.', 40, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(51, 4, 'Pin dự phòng Baseus 20000mAh', 'Phụ kiện điện thoại', 890000.00, 'baseus-20000.jpg', 'Sạc dự phòng dung lượng lớn, hỗ trợ sạc nhanh.', 35, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(52, 4, 'Tai nghe có dây Xiaomi', 'Phụ kiện điện thoại', 250000.00, 'xiaomi-wired-earphone.jpg', 'Tai nghe nhét tai giá rẻ, âm thanh tốt.', 60, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(53, 4, 'Cáp sạc Type-C to Lightning', 'Phụ kiện điện thoại', 350000.00, 'cable-typec-lightning.jpg', 'Cáp sạc hỗ trợ PD cho iPhone.', 70, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(54, 4, 'Kính cường lực iPhone 15', 'Phụ kiện điện thoại', 199000.00, 'glass-iphone15.jpg', 'Kính cường lực chống xước, chống vỡ.', 80, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(55, 5, 'Chuột Logitech MX Master 3S', 'Phụ kiện laptop', 2499000.00, 'logitech-mx3s.jpg', 'Chuột không dây cao cấp, pin sạc lâu.', 20, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(56, 5, 'Bàn phím cơ Keychron K2', 'Phụ kiện laptop', 1899000.00, 'keychron-k2.jpg', 'Bàn phím cơ bluetooth, layout 75%.', 25, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(57, 5, 'Balo Asus TUF Gaming', 'Phụ kiện laptop', 1290000.00, 'balo-asus-tuf.jpg', 'Balo chống sốc, chuyên dụng cho gaming laptop.', 15, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(58, 5, 'Đế tản nhiệt Cooler Master', 'Phụ kiện laptop', 990000.00, 'cooler-master-stand.jpg', 'Đế tản nhiệt với quạt lớn, hiệu quả cao.', 18, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(59, 5, 'Ổ cứng di động Samsung T7 1TB', 'Phụ kiện laptop', 3299000.00, 'samsung-t7-ssd.jpg', 'SSD di động tốc độ cao, hỗ trợ USB 3.2.', 12, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(60, 5, 'Hub chuyển đổi Ugreen 7-in-1', 'Phụ kiện laptop', 890000.00, 'ugreen-hub.jpg', 'Hub USB-C đa năng cho Macbook/Laptop.', 30, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(61, 6, 'Sony WH-1000XM5', 'Âm thanh', 9990000.00, 'sony-wh1000xm5.jpg', 'Tai nghe chống ồn hàng đầu, pin 30h.', 10, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(62, 6, 'Apple AirPods Pro 2', 'Âm thanh', 6490000.00, 'airpods-pro-2.jpg', 'Tai nghe true wireless cao cấp của Apple.', 25, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(63, 6, 'Loa JBL Charge 5', 'Âm thanh', 3990000.00, 'jbl-charge-5.jpg', 'Loa bluetooth chống nước, pin 20h.', 20, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(64, 6, 'Tai nghe Razer BlackShark V2', 'Âm thanh', 2990000.00, 'razer-blackshark-v2.jpg', 'Tai nghe gaming với micro siêu nhạy.', 15, 1, '2025-09-23 08:23:05', '2025-09-23 08:23:05'),
(65, 2, 'HP Spectre x360 14', 'Laptop', 37990000.00, 'hp-spectre-x360.jpg', 'Laptop 2-in-1 cao cấp, màn OLED cảm ứng.', 9, 1, '2025-09-23 08:23:20', '2025-09-23 08:23:20'),
(66, 2, 'Lenovo ThinkPad X1 Carbon Gen 11', 'Laptop', 42990000.00, 'lenovo-x1-carbon-gen11.jpg', 'Doanh nhân cao cấp, siêu bền, pin lâu.', 11, 1, '2025-09-23 08:23:20', '2025-09-23 08:23:20'),
(67, 3, 'iPad Air 5 2022', 'Tablet', 16990000.00, 'ipad-air-5.jpg', 'Chip M1, hỗ trợ Apple Pencil 2.', 14, 1, '2025-09-23 08:23:20', '2025-09-23 08:23:20'),
(68, 3, 'Huawei MatePad 11 2023', 'Tablet', 12990000.00, 'huawei-matepad-11.jpg', 'Màn hình 120Hz, hỗ trợ bút M-Pencil.', 16, 1, '2025-09-23 08:23:20', '2025-09-23 08:23:20'),
(69, 6, 'Loa Bose SoundLink Flex', 'Âm thanh', 4990000.00, 'bose-soundlink-flex.jpg', 'Loa nhỏ gọn, âm bass mạnh.', 12, 1, '2025-09-23 08:23:20', '2025-09-23 08:23:20'),
(70, 6, 'Tai nghe Sennheiser Momentum 4 Wireless', 'Âm thanh', 8990000.00, 'sennheiser-momentum4.jpg', 'Tai nghe chống ồn, pin 60h.', 8, 1, '2025-09-23 08:23:20', '2025-09-23 08:23:20'),
(71, 7, 'Garmin Forerunner 265', 'Đồng hồ thông minh', 8990000.00, 'garmin-forerunner-265.jpg', 'Đồng hồ thể thao GPS chuyên nghiệp.', 10, 1, '2025-09-23 08:23:21', '2025-09-23 08:23:21'),
(72, 7, 'Amazfit GTR 4', 'Đồng hồ thông minh', 4990000.00, 'amazfit-gtr4.jpg', 'Pin 14 ngày, theo dõi sức khỏe toàn diện.', 20, 1, '2025-09-23 08:23:21', '2025-09-23 08:23:21');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `role_type` enum('full_admin','limited_admin','customer','guest') DEFAULT 'guest',
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `roles`
--

INSERT INTO `roles` (`id`, `role_name`, `role_type`, `description`, `created_at`) VALUES
(1, 'guest', 'guest', 'Khách chưa đăng nhập', '2025-09-09 15:06:45'),
(2, 'customer', 'customer', 'Khách hàng đã đăng ký', '2025-09-09 15:06:45'),
(3, 'super_admin', 'full_admin', 'Quản trị viên toàn quyền', '2025-09-09 15:06:45'),
(4, 'product_admin', 'limited_admin', 'Quản trị viên sản phẩm', '2025-09-09 15:06:45'),
(5, 'order_admin', 'limited_admin', 'Quản trị viên đơn hàng', '2025-09-09 15:06:45'),
(6, 'content_admin', 'limited_admin', 'Quản trị viên nội dung', '2025-09-09 15:06:45'),
(7, 'report_admin', 'limited_admin', 'Quản trị viên báo cáo', '2025-09-09 15:06:45');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `role_permission`
--

CREATE TABLE `role_permission` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `role_permission`
--

INSERT INTO `role_permission` (`role_id`, `permission_id`) VALUES
(1, 1),
(2, 2),
(2, 3),
(2, 7),
(2, 12),
(2, 15),
(2, 16),
(2, 17),
(2, 20),
(3, 1),
(3, 2),
(3, 3),
(3, 4),
(3, 5),
(3, 6),
(3, 7),
(3, 8),
(3, 9),
(3, 10),
(3, 11),
(3, 12),
(3, 13),
(3, 14),
(3, 15),
(3, 16),
(3, 17),
(3, 18),
(3, 19),
(3, 20),
(3, 21),
(3, 22),
(3, 23),
(3, 24),
(3, 25),
(3, 26),
(4, 6),
(4, 7),
(4, 8),
(4, 9),
(4, 10),
(4, 11),
(4, 12),
(4, 13),
(4, 14),
(5, 15),
(5, 16),
(5, 17),
(5, 18),
(5, 19),
(5, 20),
(6, 21),
(6, 22),
(6, 23),
(6, 24),
(7, 25),
(7, 26);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `card` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `reset_token_expiry` datetime DEFAULT NULL,
  `password_changed` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `phone`, `password`, `reset_token`, `address`, `card`, `is_active`, `created_at`, `updated_at`, `reset_token_expiry`, `password_changed`) VALUES
(1, 'Super Admin', 'admin@example.com', 'adasdadad', '$2y$10$dz.9Sjy6t/zNmc4b3S5g8OBOv/r3zZg0VeDqp/zRhqmdyPySPWZMS', NULL, 'adasdadadasd', NULL, 1, '2025-09-09 15:06:46', '2025-09-25 17:40:26', NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_role`
--

CREATE TABLE `user_role` (
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `user_role`
--

INSERT INTO `user_role` (`user_id`, `role_id`) VALUES
(1, 3),
(2, 2),
(3, 2),
(7, 2),
(8, 2),
(9, 2),
(10, 2),
(11, 2);

--
-- Chỉ mục cho các bảng đã đổ
--
ALTER TABLE product 
  ADD brand VARCHAR(100) AFTER product_name;

CREATE TABLE product_attributes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  attr_name VARCHAR(100) NOT NULL,
  attr_value VARCHAR(255) NOT NULL,
  FOREIGN KEY (product_id) REFERENCES product(id)
);

CREATE TABLE search_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  keyword VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tìm kiếm toàn văn
CREATE FULLTEXT INDEX idx_product_name_desc ON product(product_name, description);

-- Lọc nhanh theo brand, price, category
CREATE INDEX idx_product_price ON product(price);
CREATE INDEX idx_product_brand ON product(brand);
CREATE INDEX idx_product_category ON product(category_id);

-- Samsung
UPDATE product SET brand = 'Samsung'
WHERE product_name LIKE 'Samsung%';

-- Apple
UPDATE product SET brand = 'Apple'
WHERE product_name LIKE 'iPhone%'
   OR product_name LIKE 'Apple%';

-- Xiaomi
UPDATE product SET brand = 'Xiaomi'
WHERE product_name LIKE 'Xiaomi%';

-- Realme
UPDATE product SET brand = 'Realme'
WHERE product_name LIKE 'Realme%';

-- Dell
UPDATE product SET brand = 'Dell'
WHERE product_name LIKE 'Dell%';

-- Asus
UPDATE product SET brand = 'Asus'
WHERE product_name LIKE 'Asus%';

-- Lenovo
UPDATE product SET brand = 'Lenovo'
WHERE product_name LIKE 'Lenovo%';

-- Baseus
UPDATE product SET brand = 'Baseus'
WHERE product_name LIKE 'Baseus%';

-- Anker
UPDATE product SET brand = 'Anker'
WHERE product_name LIKE 'Anker%';

-- Logitech
UPDATE product SET brand = 'Logitech'
WHERE product_name LIKE 'Logitech%';

-- Keychron
UPDATE product SET brand = 'Keychron'
WHERE product_name LIKE 'Keychron%';

-- Cooler Master
UPDATE product SET brand = 'Cooler Master'
WHERE product_name LIKE 'Cooler Master%';

-- Ugreen
UPDATE product SET brand = 'Ugreen'
WHERE product_name LIKE 'Ugreen%';

-- Sony
UPDATE product SET brand = 'Sony'
WHERE product_name LIKE 'Sony%';

-- JBL
UPDATE product SET brand = 'JBL'
WHERE product_name LIKE 'JBL%';

-- Razer
UPDATE product SET brand = 'Razer'
WHERE product_name LIKE 'Razer%';

-- HP
UPDATE product SET brand = 'HP'
WHERE product_name LIKE 'HP%';

-- Huawei
UPDATE product SET brand = 'Huawei'
WHERE product_name LIKE 'Huawei%';

-- Bose
UPDATE product SET brand = 'Bose'
WHERE product_name LIKE 'Bose%';

-- Sennheiser
UPDATE product SET brand = 'Sennheiser'
WHERE product_name LIKE 'Sennheiser%';

-- Garmin
UPDATE product SET brand = 'Garmin'
WHERE product_name LIKE 'Garmin%';

-- Amazfit
UPDATE product SET brand = 'Amazfit'
WHERE product_name LIKE 'Amazfit%';

--
-- Chỉ mục cho bảng `advertisement`
--
ALTER TABLE `advertisement`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_id` (`cart_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Chỉ mục cho bảng `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `dim_date`
--
ALTER TABLE `dim_date`
  ADD PRIMARY KEY (`date_id`);

--
-- Chỉ mục cho bảng `dim_product`
--
ALTER TABLE `dim_product`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Chỉ mục cho bảng `fact_sales`
--
ALTER TABLE `fact_sales`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `date_id` (`date_id`);

--
-- Chỉ mục cho bảng `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Chỉ mục cho bảng `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Chỉ mục cho bảng `permission`
--
ALTER TABLE `permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `permission_name` (`permission_name`);

--
-- Chỉ mục cho bảng `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Chỉ mục cho bảng `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `role_permission`
--
ALTER TABLE `role_permission`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `permission_id` (`permission_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Chỉ mục cho bảng `user_role`
--
ALTER TABLE `user_role`
  ADD PRIMARY KEY (`user_id`,`role_id`),
  ADD KEY `role_id` (`role_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `advertisement`
--
ALTER TABLE `advertisement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- AUTO_INCREMENT cho bảng `category`
--
ALTER TABLE `category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `fact_sales`
--
ALTER TABLE `fact_sales`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=190;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=141;

--
-- AUTO_INCREMENT cho bảng `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT cho bảng `permission`
--
ALTER TABLE `permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT cho bảng `product`
--
ALTER TABLE `product`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT cho bảng `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

--
-- Các ràng buộc cho bảng `dim_product`
--
ALTER TABLE `dim_product`
  ADD CONSTRAINT `dim_product_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  ADD CONSTRAINT `dim_product_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

--
-- Các ràng buộc cho bảng `fact_sales`
--
ALTER TABLE `fact_sales`
  ADD CONSTRAINT `fact_sales_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fact_sales_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `dim_product` (`product_id`),
  ADD CONSTRAINT `fact_sales_ibfk_3` FOREIGN KEY (`date_id`) REFERENCES `dim_date` (`date_id`);

--
-- Các ràng buộc cho bảng `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD CONSTRAINT `login_attempts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

--
-- Các ràng buộc cho bảng `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

--
-- Các ràng buộc cho bảng `role_permission`
--
ALTER TABLE `role_permission`
  ADD CONSTRAINT `role_permission_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `user_role`
--
ALTER TABLE `user_role`
  ADD CONSTRAINT `user_role_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
