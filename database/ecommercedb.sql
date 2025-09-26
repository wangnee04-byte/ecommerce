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

--
-- Đang đổ dữ liệu cho bảng `cart_items`
--

INSERT INTO `cart_items` (`id`, `cart_id`, `product_id`, `quantity`, `added_at`) VALUES
(86, 2, 3, 1, '2025-09-26 13:09:56');

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

INSERT INTO `category` (`id`, `product_type`, `description`, `is_active`, `created_at`) VALUES
(1, 'Điện thoại', NULL, 1, '2025-09-09 15:09:31'),
(2, 'Laptop', NULL, 1, '2025-09-09 15:09:31'),
(3, 'Đồng hồ', NULL, 1, '2025-09-09 15:09:31'),
(4, 'Phụ kiện', NULL, 1, '2025-09-09 15:09:31'),
(5, 'Điện thoại', 'Các loại điện thoại smartphone', 1, '2025-09-23 08:22:05'),
(6, 'Laptop', 'Máy tính xách tay', 1, '2025-09-23 08:22:05'),
(7, 'Tablet', 'Máy tính bảng', 1, '2025-09-23 08:22:05'),
(8, 'Phụ kiện điện thoại', 'Ốp lưng, sạc, pin dự phòng...', 1, '2025-09-23 08:22:05'),
(9, 'Phụ kiện laptop', 'Chuột, bàn phím, balo...', 1, '2025-09-23 08:22:05'),
(10, 'Âm thanh', 'Tai nghe, loa bluetooth...', 1, '2025-09-23 08:22:05'),
(11, 'Đồng hồ', 'Đồng hồ thông minh', 1, '2025-09-23 08:22:05');

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

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `fullname`, `email`, `phone`, `address`, `note`, `status`, `order_date`, `total`, `updated_at`, `payment_method`, `paypal_order_id`, `payment_status`, `momo_transaction_id`, `paypal_transaction_id`, `paypal_payer_email`, `payment_date`, `created_at`) VALUES
(102, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancelled', '2025-09-20 08:31:53', 133560000.00, '2025-09-22 18:25:44', 'paypal', '6A158817D3405053W', 'failed', NULL, NULL, NULL, '2025-09-20 08:32:06', '2025-09-20 15:31:53'),
(110, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancelled', '2025-09-20 08:56:53', 33390000.00, '2025-09-22 17:57:25', 'paypal', '2BX17574NG1983445', 'failed', NULL, NULL, NULL, '2025-09-20 08:57:24', '2025-09-20 15:56:53'),
(112, 3, NULL, NULL, NULL, NULL, NULL, 'pending', '2025-09-20 08:58:23', 33390000.00, '2025-09-20 08:58:23', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 15:58:23'),
(113, 3, NULL, NULL, NULL, NULL, NULL, 'cancelled', '2025-09-20 09:38:21', 33390000.00, '2025-09-24 11:40:38', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-20 16:38:21'),
(114, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancelled', '2025-09-20 09:56:58', 33390000.00, '2025-09-22 18:28:14', 'paypal', '6DH473653S930610E', 'failed', NULL, NULL, NULL, '2025-09-20 09:57:52', '2025-09-20 16:56:58'),
(115, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancelled', '2025-09-20 10:00:59', 33390000.00, '2025-09-21 17:47:01', 'cod', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-20 17:00:59'),
(116, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancel_request', '2025-09-20 10:01:55', 33390000.00, '2025-09-22 18:23:20', 'momo', NULL, 'paid', 'MOMO_1758362517_116', NULL, NULL, '2025-09-20 10:01:57', '2025-09-20 17:01:55'),
(117, 3, 'Quang Huy Nguyen', NULL, '0886924681', 'Vinh,Nghe An', NULL, 'cancelled', '2025-09-20 14:38:31', 33390000.00, '2025-09-22 18:24:36', 'paypal', '39K59123HC304090B', 'failed', NULL, NULL, NULL, '2025-09-20 14:41:38', '2025-09-20 21:38:31'),
(118, 3, 'quang', NULL, '0886922226', 'vinhfffff', NULL, 'pending', '2025-09-20 14:40:28', 33390000.00, '2025-09-22 13:16:19', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 21:40:28'),
(119, 3, NULL, NULL, '0886922226', 'vinhfffff', NULL, 'cancelled', '2025-09-20 14:49:23', 66780000.00, '2025-09-22 13:16:23', 'cod', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-20 21:49:23'),
(120, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancelled', '2025-09-20 14:49:31', 33390000.00, '2025-09-22 18:23:44', 'momo', NULL, 'failed', 'MOMO_1758379773_120', NULL, NULL, '2025-09-20 14:49:33', '2025-09-20 21:49:31'),
(121, 3, 'Nguyen Huy Quang', NULL, '0886924681', 'hà nội', NULL, 'cancelled', '2025-09-20 14:49:40', 33390000.00, '2025-09-22 18:27:11', 'paypal', '3A740319T3420432U', 'failed', NULL, NULL, NULL, NULL, '2025-09-20 21:49:40'),
(122, 10, 'Quang Huy Nguyen', NULL, '0886924681', 'Vinh,Nghe An', NULL, 'confirmed', '2025-09-20 14:57:59', 141340000.00, '2025-09-20 14:58:04', 'cod', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 21:57:59'),
(123, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancelled', '2025-09-20 15:54:32', 33390000.00, '2025-09-22 17:27:38', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-20 22:54:32'),
(124, 3, NULL, NULL, NULL, NULL, NULL, 'pending', '2025-09-20 15:54:45', 33390000.00, '2025-09-20 15:54:45', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 22:54:45'),
(125, 3, NULL, NULL, NULL, NULL, NULL, 'pending', '2025-09-20 15:54:57', 33390000.00, '2025-09-20 15:54:57', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 22:54:57'),
(126, 3, NULL, NULL, NULL, NULL, NULL, 'cancelled', '2025-09-20 15:56:12', 66780000.00, '2025-09-22 18:09:33', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-20 22:56:12'),
(127, 1, 'Super Admin', NULL, 'adasdadad', 'adasdadadasd', NULL, 'pending', '2025-09-20 15:56:27', 33390000.00, '2025-09-20 15:56:34', 'paypal', '21A684846S196312B', 'pending', NULL, NULL, NULL, NULL, '2025-09-20 22:56:27'),
(128, 3, NULL, NULL, NULL, NULL, NULL, 'cancelled', '2025-09-20 15:57:09', 100170000.00, '2025-09-22 18:21:09', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-20 22:57:09'),
(129, 3, 'Quang Huy Nguyen', NULL, '0886924681', 'Vinh,Nghe An', NULL, 'cancel_request', '2025-09-20 15:59:59', 133560000.00, '2025-09-22 11:55:35', 'momo', NULL, 'paid', 'MOMO_1758384002_129', NULL, NULL, '2025-09-20 16:00:02', '2025-09-20 22:59:59'),
(130, 3, NULL, NULL, NULL, NULL, NULL, 'cancel_request', '2025-09-20 16:00:10', 33390000.00, '2025-09-22 16:58:51', 'momo', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 23:00:10'),
(131, 3, NULL, NULL, NULL, NULL, NULL, 'cancel_request', '2025-09-20 16:18:16', 66780000.00, '2025-09-22 17:09:54', 'momo', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 23:18:16'),
(132, 3, NULL, NULL, NULL, NULL, NULL, 'cancel_request', '2025-09-20 16:18:26', 94770000.00, '2025-09-22 17:11:51', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 23:18:26'),
(133, 3, NULL, NULL, NULL, NULL, NULL, 'pending', '2025-09-20 16:45:27', 94770000.00, '2025-09-20 16:45:27', 'cod', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-20 23:45:27'),
(134, 3, NULL, NULL, NULL, NULL, NULL, 'cancelled', '2025-09-21 14:33:02', 66780000.00, '2025-09-22 17:27:27', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-21 21:33:02'),
(135, 3, NULL, NULL, NULL, NULL, NULL, 'cancelled', '2025-09-21 14:33:02', 66780000.00, '2025-09-22 18:02:53', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-21 21:33:02'),
(136, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancel_request', '2025-09-21 14:48:24', 66780000.00, '2025-09-22 12:03:18', 'paypal', '2XW424408C217874W', 'paid', NULL, NULL, NULL, '2025-09-21 14:48:57', '2025-09-21 21:48:24'),
(137, 3, NULL, NULL, NULL, NULL, NULL, 'cancel_request', '2025-09-21 16:11:10', 33390000.00, '2025-09-22 17:09:44', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-21 23:11:10'),
(138, 3, NULL, NULL, NULL, NULL, NULL, 'cancelled', '2025-09-22 12:15:25', 33390000.00, '2025-09-22 17:20:07', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-22 19:15:25'),
(139, 3, NULL, NULL, NULL, NULL, NULL, 'cancelled', '2025-09-22 12:58:56', 33390000.00, '2025-09-22 17:19:49', 'momo', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-22 19:58:56'),
(140, 3, NULL, NULL, NULL, NULL, NULL, 'cancel_request', '2025-09-22 12:59:18', 33390000.00, '2025-09-22 17:01:51', 'cod', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-22 19:59:18'),
(141, 3, NULL, NULL, NULL, NULL, NULL, 'cancel_request', '2025-09-22 12:59:35', 33390000.00, '2025-09-22 16:59:51', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-22 19:59:35'),
(142, 3, 'Nguyen Huy Quang', NULL, '0886922226', 'vinh', NULL, 'cancel_request', '2025-09-22 13:02:16', 33390000.00, '2025-09-22 16:59:47', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-22 20:02:16'),
(143, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-22 13:13:49', 33390000.00, '2025-09-22 18:01:40', 'paypal', '35P46430EH3224704', 'failed', NULL, NULL, NULL, '2025-09-22 13:15:25', '2025-09-22 20:13:49'),
(144, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-22 16:49:40', 33390000.00, '2025-09-22 18:01:48', 'paypal', '5EP55380C73278829', 'failed', NULL, NULL, NULL, '2025-09-22 16:50:22', '2025-09-22 23:49:40'),
(145, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-22 18:18:56', 33390000.00, '2025-09-22 18:23:10', 'cod', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-23 01:18:56'),
(146, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-22 18:19:06', 33390000.00, '2025-09-22 18:20:43', 'momo', NULL, 'failed', 'MOMO_1758565147_146', NULL, NULL, '2025-09-22 18:19:07', '2025-09-23 01:19:06'),
(147, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-22 18:19:13', 33390000.00, '2025-09-22 18:20:41', 'paypal', '00G12229K5861384G', 'failed', NULL, NULL, NULL, '2025-09-22 18:19:41', '2025-09-23 01:19:13'),
(148, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-22 18:27:25', 33390000.00, '2025-09-22 18:27:25', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-23 01:27:25'),
(149, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-22 18:27:42', 100170000.00, '2025-09-22 18:28:05', 'momo', NULL, 'failed', 'MOMO_1758565663_149', NULL, NULL, '2025-09-22 18:27:43', '2025-09-23 01:27:42'),
(150, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 09:56:26', 66780000.00, '2025-09-24 09:56:26', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 16:56:26'),
(151, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 09:58:28', 66780000.00, '2025-09-24 09:58:28', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 16:58:28'),
(152, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 09:59:06', 33390000.00, '2025-09-24 09:59:06', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 16:59:06'),
(153, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:00:21', 27990000.00, '2025-09-24 10:00:21', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:00:21'),
(154, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:00:21', 27990000.00, '2025-09-24 10:00:21', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:00:21'),
(155, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:03:31', 33390000.00, '2025-09-24 10:03:31', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:03:31'),
(156, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:03:31', 33390000.00, '2025-09-24 10:03:31', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:03:31'),
(157, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:05:57', 33390000.00, '2025-09-24 10:05:57', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:05:57'),
(158, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:07:41', 33390000.00, '2025-09-24 10:07:41', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:07:41'),
(159, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:08:19', 66780000.00, '2025-09-24 10:08:19', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:08:19'),
(160, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:11:49', 33390000.00, '2025-09-24 10:11:49', 'momo', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:11:49'),
(161, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 10:11:49', 33390000.00, '2025-09-24 10:11:49', 'momo', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 17:11:49'),
(162, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-24 10:11:55', 33390000.00, '2025-09-24 10:32:21', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-24 17:11:55'),
(163, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'confirmed', '2025-09-24 10:16:50', 66780000.00, '2025-09-24 10:24:59', 'paypal', '3C914824BC865632M', 'paid', NULL, NULL, NULL, '2025-09-24 10:24:59', '2025-09-24 17:16:50'),
(164, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-24 10:16:50', 66780000.00, '2025-09-24 10:32:38', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-24 17:16:50'),
(165, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-24 10:26:53', 66780000.00, '2025-09-24 11:40:11', 'paypal', '6Y828940XE770752H', 'failed', NULL, NULL, NULL, '2025-09-24 10:27:05', '2025-09-24 17:26:53'),
(166, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancel_request', '2025-09-24 10:31:25', 66780000.00, '2025-09-24 10:32:24', 'paypal', '7TM79999N5639841X', 'paid', NULL, NULL, NULL, '2025-09-24 10:31:36', '2025-09-24 17:31:25'),
(167, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-24 10:45:55', 27990000.00, '2025-09-24 11:39:50', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-24 17:45:55'),
(168, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-24 10:46:06', 61380000.00, '2025-09-24 11:39:46', 'paypal', '2DS071734K057440M', 'failed', NULL, NULL, NULL, NULL, '2025-09-24 17:46:06'),
(169, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancel_request', '2025-09-24 11:37:46', 61380000.00, '2025-09-24 11:40:48', 'paypal', '8LJ210166N194560U', 'paid', NULL, NULL, NULL, '2025-09-24 11:38:27', '2025-09-24 18:37:46'),
(170, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 11:58:45', 33390000.00, '2025-09-24 11:58:45', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 18:58:45'),
(171, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 11:59:52', 33390000.00, '2025-09-24 11:59:52', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 18:59:52'),
(172, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 12:41:36', 59380000.00, '2025-09-24 12:41:36', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 19:41:36'),
(173, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'confirmed', '2025-09-24 12:41:59', 59380000.00, '2025-09-24 12:42:32', 'paypal', '71A01733YM868332N', 'paid', NULL, NULL, NULL, '2025-09-24 12:42:32', '2025-09-24 19:41:59'),
(174, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'confirmed', '2025-09-24 13:01:14', 33390000.00, '2025-09-24 14:03:59', 'paypal', '78H10521AN082502W', 'paid', NULL, NULL, NULL, '2025-09-24 14:03:59', '2025-09-24 20:01:14'),
(175, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'confirmed', '2025-09-24 15:51:09', 37990000.00, '2025-09-24 15:52:08', 'paypal', '29W305284E866663E', 'paid', NULL, NULL, NULL, '2025-09-24 15:52:08', '2025-09-24 22:51:09'),
(176, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 16:03:50', 333900000.00, '2025-09-24 16:03:50', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 23:03:50'),
(177, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 16:03:50', 333900000.00, '2025-09-24 16:03:50', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 23:03:50'),
(178, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 16:03:50', 333900000.00, '2025-09-24 16:03:50', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 23:03:50'),
(179, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-24 16:03:50', 333900000.00, '2025-09-24 16:03:50', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-24 23:03:50'),
(180, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'confirmed', '2025-09-25 14:53:29', 333900000.00, '2025-09-25 14:53:35', 'paypal', '6S95986776657872U', 'pending', NULL, NULL, NULL, NULL, '2025-09-25 21:53:29'),
(181, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-25 15:57:39', 333900000.00, '2025-09-25 15:57:39', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-25 22:57:39'),
(182, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancel_request', '2025-09-26 09:58:29', 25990000.00, '2025-09-26 09:59:04', 'paypal', '166495006F162781U', 'paid', NULL, NULL, NULL, '2025-09-26 09:58:51', '2025-09-26 16:58:29'),
(183, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'cancelled', '2025-09-26 09:59:15', 25990000.00, '2025-09-26 09:59:30', 'paypal', NULL, 'failed', NULL, NULL, NULL, NULL, '2025-09-26 16:59:15'),
(184, 1, 'Super Admin', '', 'adasdadad', 'adasdadadasd', NULL, 'confirmed', '2025-09-26 11:38:06', 33390000.00, '2025-09-26 11:38:07', 'cod', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-26 18:38:06'),
(185, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-26 13:00:56', 36980000.00, '2025-09-26 13:00:56', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-26 20:00:56'),
(186, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-26 13:02:11', 36980000.00, '2025-09-26 13:02:11', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-26 20:02:11'),
(187, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'confirmed', '2025-09-26 13:02:15', 36980000.00, '2025-09-26 13:02:17', 'momo', NULL, 'paid', 'MOMO_1758891737_187', NULL, NULL, '2025-09-26 13:02:17', '2025-09-26 20:02:15'),
(188, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-26 13:10:04', 25990000.00, '2025-09-26 13:10:04', 'cod', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-26 20:10:04'),
(189, 3, 'Nguyen Huy Quang', '', '0886922226', 'vinh', NULL, 'pending', '2025-09-26 14:03:31', 25990000.00, '2025-09-26 14:03:31', 'paypal', NULL, 'pending', NULL, NULL, NULL, NULL, '2025-09-26 21:03:31');

-- --------------------------------------------------------

--
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
-- Đang đổ dữ liệu cho bảng `order_details`
--

INSERT INTO `order_details` (`id`, `order_id`, `product_id`, `price`, `quantity`, `total`) VALUES
(39, 102, 1, 33390000.00, 4, 0.00),
(47, 110, 1, 33390000.00, 1, 0.00),
(49, 112, 1, 33390000.00, 1, 0.00),
(50, 113, 1, 33390000.00, 1, 0.00),
(51, 114, 1, 33390000.00, 1, 0.00),
(52, 115, 1, 33390000.00, 1, 0.00),
(53, 116, 1, 33390000.00, 1, 0.00),
(54, 117, 1, 33390000.00, 1, 0.00),
(55, 118, 1, 33390000.00, 1, 0.00),
(56, 119, 1, 33390000.00, 2, 0.00),
(57, 120, 1, 33390000.00, 1, 0.00),
(58, 121, 1, 33390000.00, 1, 0.00),
(59, 122, 6, 34990000.00, 1, 0.00),
(60, 122, 5, 7990000.00, 1, 0.00),
(61, 122, 4, 10990000.00, 1, 0.00),
(62, 122, 3, 25990000.00, 1, 0.00),
(63, 122, 2, 27990000.00, 1, 0.00),
(64, 122, 1, 33390000.00, 1, 0.00),
(65, 123, 1, 33390000.00, 1, 0.00),
(66, 124, 1, 33390000.00, 1, 0.00),
(67, 125, 1, 33390000.00, 1, 0.00),
(68, 126, 1, 33390000.00, 2, 0.00),
(69, 127, 1, 33390000.00, 1, 0.00),
(70, 128, 1, 33390000.00, 3, 0.00),
(71, 129, 1, 33390000.00, 4, 0.00),
(72, 130, 1, 33390000.00, 1, 0.00),
(73, 131, 1, 33390000.00, 2, 0.00),
(74, 132, 1, 33390000.00, 2, 0.00),
(75, 132, 2, 27990000.00, 1, 0.00),
(76, 133, 1, 33390000.00, 2, 0.00),
(77, 133, 2, 27990000.00, 1, 0.00),
(78, 134, 1, 33390000.00, 2, 0.00),
(79, 135, 1, 33390000.00, 2, 0.00),
(80, 136, 1, 33390000.00, 2, 0.00),
(81, 137, 1, 33390000.00, 1, 0.00),
(82, 138, 1, 33390000.00, 1, 0.00),
(83, 139, 1, 33390000.00, 1, 0.00),
(84, 140, 1, 33390000.00, 1, 0.00),
(85, 141, 1, 33390000.00, 1, 0.00),
(86, 142, 1, 33390000.00, 1, 0.00),
(87, 143, 1, 33390000.00, 1, 0.00),
(88, 144, 1, 33390000.00, 1, 0.00),
(89, 145, 1, 33390000.00, 1, 0.00),
(90, 146, 1, 33390000.00, 1, 0.00),
(91, 147, 1, 33390000.00, 1, 0.00),
(92, 148, 1, 33390000.00, 1, 0.00),
(93, 149, 1, 33390000.00, 3, 0.00),
(94, 150, 1, 33390000.00, 2, 0.00),
(95, 151, 1, 33390000.00, 2, 0.00),
(96, 152, 1, 33390000.00, 1, 0.00),
(97, 153, 2, 27990000.00, 1, 0.00),
(98, 154, 2, 27990000.00, 1, 0.00),
(99, 155, 1, 33390000.00, 1, 0.00),
(100, 156, 1, 33390000.00, 1, 0.00),
(101, 157, 1, 33390000.00, 1, 0.00),
(102, 158, 1, 33390000.00, 1, 0.00),
(103, 159, 1, 33390000.00, 2, 0.00),
(104, 160, 1, 33390000.00, 1, 0.00),
(105, 161, 1, 33390000.00, 1, 0.00),
(106, 162, 1, 33390000.00, 1, 0.00),
(107, 163, 1, 33390000.00, 2, 0.00),
(108, 164, 1, 33390000.00, 2, 0.00),
(109, 165, 1, 33390000.00, 2, 0.00),
(110, 166, 1, 33390000.00, 2, 0.00),
(111, 167, 2, 27990000.00, 1, 0.00),
(112, 168, 2, 27990000.00, 1, 0.00),
(113, 168, 1, 33390000.00, 1, 0.00),
(114, 169, 2, 27990000.00, 1, 0.00),
(115, 169, 1, 33390000.00, 1, 0.00),
(116, 170, 1, 33390000.00, 1, 0.00),
(117, 171, 1, 33390000.00, 1, 0.00),
(118, 172, 1, 33390000.00, 1, 0.00),
(119, 172, 3, 25990000.00, 1, 0.00),
(120, 173, 1, 33390000.00, 1, 0.00),
(121, 173, 3, 25990000.00, 1, 0.00),
(122, 174, 1, 33390000.00, 1, 0.00),
(123, 175, 65, 37990000.00, 1, 0.00),
(124, 176, 1, 33390000.00, 10, 0.00),
(125, 177, 1, 33390000.00, 10, 0.00),
(126, 178, 1, 33390000.00, 10, 0.00),
(127, 179, 1, 33390000.00, 10, 0.00),
(128, 180, 1, 33390000.00, 10, 0.00),
(129, 181, 1, 33390000.00, 10, 0.00),
(130, 182, 3, 25990000.00, 1, 0.00),
(131, 183, 3, 25990000.00, 1, 0.00),
(132, 184, 1, 33390000.00, 1, 0.00),
(133, 185, 4, 10990000.00, 1, 0.00),
(134, 185, 3, 25990000.00, 1, 0.00),
(135, 186, 4, 10990000.00, 1, 0.00),
(136, 186, 3, 25990000.00, 1, 0.00),
(137, 187, 4, 10990000.00, 1, 0.00),
(138, 187, 3, 25990000.00, 1, 0.00),
(139, 188, 3, 25990000.00, 1, 0.00),
(140, 189, 3, 25990000.00, 1, 0.00);

-- --------------------------------------------------------

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

--
-- Đang đổ dữ liệu cho bảng `payments`
--

INSERT INTO `payments` (`id`, `order_id`, `payment_method`, `amount`, `status`, `transaction_id`, `created_at`, `updated_at`) VALUES
(13, 102, 'paypal', 133560000.00, 'paid', '6A158817D3405053W', '2025-09-20 08:32:06', '2025-09-20 08:32:06'),
(15, 110, 'paypal', 33390000.00, 'paid', '2BX17574NG1983445', '2025-09-20 08:57:24', '2025-09-20 08:57:24'),
(17, 114, 'paypal', 33390000.00, 'paid', '6DH473653S930610E', '2025-09-20 09:57:52', '2025-09-20 09:57:52'),
(18, 116, 'momo', 33390000.00, 'paid', 'MOMO_1758362517_116', '2025-09-20 10:01:57', '2025-09-20 10:01:57'),
(19, 117, 'paypal', 33390000.00, 'paid', '39K59123HC304090B', '2025-09-20 14:41:38', '2025-09-20 14:41:38'),
(20, 120, 'momo', 33390000.00, 'paid', 'MOMO_1758379773_120', '2025-09-20 14:49:33', '2025-09-20 14:49:33'),
(21, 129, 'momo', 133560000.00, 'paid', 'MOMO_1758384002_129', '2025-09-20 16:00:02', '2025-09-20 16:00:02'),
(22, 136, 'paypal', 66780000.00, 'paid', '2XW424408C217874W', '2025-09-21 14:48:57', '2025-09-21 14:48:57'),
(23, 143, 'paypal', 33390000.00, 'paid', '35P46430EH3224704', '2025-09-22 13:15:25', '2025-09-22 13:15:25'),
(24, 144, 'paypal', 33390000.00, 'paid', '5EP55380C73278829', '2025-09-22 16:50:22', '2025-09-22 16:50:22'),
(25, 146, 'momo', 33390000.00, 'paid', 'MOMO_1758565147_146', '2025-09-22 18:19:07', '2025-09-22 18:19:07'),
(26, 147, 'paypal', 33390000.00, 'paid', '00G12229K5861384G', '2025-09-22 18:19:41', '2025-09-22 18:19:41'),
(27, 149, 'momo', 100170000.00, 'paid', 'MOMO_1758565663_149', '2025-09-22 18:27:43', '2025-09-22 18:27:43'),
(28, 163, 'paypal', 66780000.00, 'paid', '3C914824BC865632M', '2025-09-24 10:24:59', '2025-09-24 10:24:59'),
(29, 165, 'paypal', 66780000.00, 'paid', '6Y828940XE770752H', '2025-09-24 10:27:05', '2025-09-24 10:27:05'),
(30, 166, 'paypal', 66780000.00, 'paid', '7TM79999N5639841X', '2025-09-24 10:31:36', '2025-09-24 10:31:36'),
(31, 169, 'paypal', 61380000.00, 'paid', '8LJ210166N194560U', '2025-09-24 11:38:27', '2025-09-24 11:38:27'),
(32, 173, 'paypal', 59380000.00, 'paid', '71A01733YM868332N', '2025-09-24 12:42:32', '2025-09-24 12:42:32'),
(33, 174, 'paypal', 33390000.00, 'paid', '78H10521AN082502W', '2025-09-24 14:03:59', '2025-09-24 14:03:59'),
(34, 175, 'paypal', 37990000.00, 'paid', '29W305284E866663E', '2025-09-24 15:52:08', '2025-09-24 15:52:08'),
(35, 182, 'paypal', 25990000.00, 'paid', '166495006F162781U', '2025-09-26 09:58:51', '2025-09-26 09:58:51'),
(36, 187, 'momo', 36980000.00, 'paid', 'MOMO_1758891737_187', '2025-09-26 13:02:17', '2025-09-26 13:02:17');

-- --------------------------------------------------------

--
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
(1, 1, 'Samsung Galaxy S25 Ultra', 'Samsung', 33390000.00, 's25-ultra.webp', 'Flagship Samsung 2025: Snapdragon 8 Elite, RAM 12GB, bộ nhớ 256GB, pin 5000mAh, camera 200MP', 120, 1, '2025-09-09 15:10:34', '2025-09-17 10:22:55'),
(2, 1, 'Samsung Galaxy S25+', 'Samsung', 27990000.00, '', 'Màn hình Dynamic AMOLED 6.7\", RAM 8GB, bộ nhớ 256GB, hỗ trợ 5G, camera chính 50MP', 135, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(3, 1, 'Samsung Galaxy Z Flip6', 'Samsung', 25990000.00, '', 'Điện thoại màn hình gập 6.7\", RAM 8GB, bộ nhớ 256GB, camera kép 50MP', 145, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(4, 1, 'Samsung Galaxy A56 5G', 'Samsung', 10990000.00, '', 'Điện thoại tầm trung với màn hình 6.6\", Snapdragon 7s Gen 2, camera 50MP, pin 5000mAh', 138, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(5, 1, 'Samsung Galaxy A26 5G', 'Samsung', 7990000.00, '', 'Màn hình 6.5\", chip Exynos 1330, RAM 6GB, bộ nhớ 128GB, camera kép 50MP, pin 5000mAh', 142, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(6, 1, 'iPhone 16 Pro Max', 'Apple', 34990000.00, '', 'iPhone cao cấp 2025: chip A18 Pro, màn hình 6.9\", RAM 8GB, camera 48MP, pin 5000mAh', 140, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(7, 1, 'iPhone 16 Pro', 'Apple', 30990000.00, '', 'Màn hình 6.3\", chip A18 Pro, RAM 8GB, bộ nhớ 256GB, hỗ trợ 5G', 133, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(8, 1, 'iPhone 16 Plus', 'Apple', 26990000.00, '', 'Chip A17 Bionic, RAM 6GB, camera kép 48MP, pin 4900mAh', 115, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(9, 1, 'iPhone 15 Pro Max', 'Apple', 28990000.00, '', 'Màn hình 6.7\", RAM 8GB, bộ nhớ 256GB, camera tele 5x zoom', 148, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(10, 1, 'iPhone 15', 'Apple', 18990000.00, '', 'Màn hình 6.1\", RAM 6GB, bộ nhớ 128GB, hỗ trợ 5G, camera kép 48MP', 125, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(11, 1, 'Xiaomi 15 Ultra', 'Xiaomi', 24990000.00, '', 'Màn hình AMOLED 6.7\", RAM 16GB, pin 5000mAh, sạc nhanh 120W, camera 200MP', 121, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(12, 1, 'Xiaomi 15 Pro', 'Xiaomi', 20990000.00, '', 'Flagship Xiaomi với màn hình 6.73\", RAM 12GB, pin 4880mAh, sạc nhanh 120W', 137, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(13, 1, 'Xiaomi 14T Pro', 'Xiaomi', 15990000.00, '', 'Màn hình AMOLED 6.7\", RAM 12GB, pin 5000mAh, sạc nhanh 120W', 149, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(14, 1, 'Xiaomi Redmi Note 14 Pro+', 'Xiaomi', 9990000.00, '', 'Màn hình AMOLED 6.67\", Dimensity 8200 Ultra, RAM 8GB, pin 5000mAh', 118, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(15, 1, 'Xiaomi Redmi Note 14', 'Xiaomi', 6990000.00, '', 'Màn hình AMOLED 6.6\", Snapdragon 7s Gen 2, RAM 6GB, camera 100MP', 132, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(16, 1, 'Realme GT 6 Pro', 'Realme', 18990000.00, '', 'Flagship Realme với màn hình 6.78\", RAM 16GB, pin 5500mAh, sạc nhanh 120W', 127, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(17, 1, 'Realme GT Neo 6', 'Realme', 13990000.00, '', 'Màn hình AMOLED 6.7\", RAM 12GB, pin 5000mAh, camera 50MP', 146, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(18, 1, 'Realme 13 Pro+', 'Realme', 10990000.00, '', 'Màn hình AMOLED 6.7\", Snapdragon 7s Gen 3, RAM 8GB, pin 5000mAh', 141, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(19, 1, 'Realme 12+', 'Realme', 7990000.00, '', 'Chip Dimensity 7050, RAM 8GB, bộ nhớ 256GB, camera 50MP OIS', 119, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(20, 1, 'Realme C67', 'Realme', 5990000.00, '', 'Màn hình AMOLED 6.6\", RAM 6GB, camera 108MP, pin 5000mAh, sạc 33W', 134, 1, '2025-09-09 15:10:34', '2025-09-09 16:01:50'),
(21, 3, 'Samsung Galaxy Watch 8', 'Samsung', 10448155.00, '', 'Galaxy Watch 8: màn AMOLED 1.6″, lưu trữ 16 GB, pin 410mAh, GPS, chống nước 5ATM', 129, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(22, 3, 'Samsung Galaxy Watch 8 Classic', 'Samsung', 14599115.00, '', 'Màn 1.5″ AMOLED, viền xoay bằng thép không gỉ, pin 300mAh, LTE tùy chọn', 149, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(23, 3, 'Samsung Galaxy Watch Ultra', 'Samsung', 15306665.00, '', 'Màn 1.9″ Super AMOLED, khung titanium, pin lớn 599mAh, GPS độ chính xác cao', 107, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(24, 3, 'Samsung Galaxy Watch 7', 'Samsung', 6132100.00, '', 'Thiết kế mỏng nhẹ, GPS, theo dõi giấc ngủ, pin dùng cả ngày', 143, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(25, 3, 'Samsung Galaxy Watch FE', 'Samsung', 4717000.00, '', 'Màn AMOLED, GPS, thiết kế đơn giản, pin 300mAh, nhẹ và giá mềm', 140, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(26, 3, 'Apple Watch Series 9 (Nhôm)', 'Apple', 10499000.00, '', 'Siri chạy trên thiết bị, chip S9 SiP, màn Retina LTPO OLED luôn bật, chống nước 50 m', 120, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(27, 3, 'Apple Watch Series 9 (Thép)', 'Apple', 18990000.00, '', 'Vỏ thép không gỉ, màn sáng 2000 nits, nút Action, phần mềm watchOS 10', 131, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(28, 3, 'Apple Watch Series 10', 'Apple', 10799000.00, '', 'Phiên bản GPS + Cellular, cảm biến ECG, màn Retina OLED luôn bật, Titan bền', 143, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(29, 3, 'Apple Watch Ultra 2', 'Apple', 18990000.00, '', 'Pin 36 giờ, tính năng thể thao chuyên sâu, nút Tác Vụ tùy chỉnh, chống nước 100 m', 123, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(30, 3, 'Apple Watch SE (thế hệ 2)', 'Apple', 6990000.00, '', 'Chip S8 giống Watch 8, GPS, theo dõi sức khỏe, giá dễ chịu', 137, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(31, 3, 'Xiaomi Redmi Watch 5 Lite', 'Xiaomi', 1270000.00, '', 'Màn 1.55″ TFT, pin dùng 10 ngày, theo dõi nhịp tim & giấc ngủ', 114, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(32, 3, 'Xiaomi Redmi Watch 5 Active', 'Xiaomi', 2830500.00, '', 'Màn AMOLED 1.91″, GPS tích hợp, vỏ nhẹ, pin dùng nhiều ngày', 111, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(33, 3, 'Xiaomi Watch S4 Sport', 'Xiaomi', 6485875.00, '', 'Màn 1.96″ AMOLED lớn, theo dõi nhịp tim, pin 480mAh, GPS+BT', 112, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(34, 3, 'Xiaomi Watch 2 Pro', 'Xiaomi', 6721725.00, '', 'Always-on display, Wi-Fi, GPS chính xác, pin 500mAh', 130, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(35, 3, 'Xiaomi Watch S1 Active', 'Xiaomi', 4952850.00, '', 'Màn AMOLED 1.43″, pin 420mAh, vỏ nhẹ, nhiều mặt đồng hồ', 113, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(36, 3, 'Realme Watch 3 Pro', 'Realme', 1890000.00, '', 'GPS kép, màn 1.78″, pin dùng 14 ngày, theo dõi thể thao', 126, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(37, 3, 'Realme Band 3', 'Realme', 890000.00, '', 'Vòng tay nhỏ gọn, theo dõi nhịp tim, SPO2, pin 12 ngày', 140, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(38, 3, 'Realme Watch 3', 'Realme', 1690000.00, '', 'Màn 1.8″ IPS, theo dõi sức khỏe, pin 288mAh dùng 10 ngày', 120, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(39, 3, 'Realme Watch S100', 'Realme', 2190000.00, '', 'Khung thép, màn OLED, pin dùng tới 10 ngày, nhiều chế độ tập luyện', 134, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
(40, 3, 'Realme Watch 2 Pro', 'Realme', 2990000.00, '', 'GPS hai băng tần, màn 1.75″, pin 390mAh, theo dõi nâng cao', 106, 1, '2025-09-09 15:10:59', '2025-09-09 16:01:50'),
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
(71, 7, 'Garmin Forerunner 265', 'Đồng hồ', 8990000.00, 'garmin-forerunner-265.jpg', 'Đồng hồ thể thao GPS chuyên nghiệp.', 10, 1, '2025-09-23 08:23:21', '2025-09-23 08:23:21'),
(72, 7, 'Amazfit GTR 4', 'Đồng hồ', 4990000.00, 'amazfit-gtr4.jpg', 'Pin 14 ngày, theo dõi sức khỏe toàn diện.', 20, 1, '2025-09-23 08:23:21', '2025-09-23 08:23:21');

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
(1, 'Super Admin', 'admin@example.com', 'adasdadad', '$2y$10$dz.9Sjy6t/zNmc4b3S5g8OBOv/r3zZg0VeDqp/zRhqmdyPySPWZMS', NULL, 'adasdadadasd', NULL, 1, '2025-09-09 15:06:46', '2025-09-25 17:40:26', NULL, 0),
(2, 'Nguyen Van A', 'nguyenvana@example.com', '0886924444', '$2y$10$OzGyXikFUDm8Sh2QDHYopO20kS9sicBo/KlWduTLpNGurxbnvRgye', NULL, NULL, NULL, 1, '2025-09-09 15:24:24', '2025-09-09 15:24:24', NULL, 0),
(3, 'Nguyen Huy Quang', 'huyquang@gmail.com', '0886922226', '$2y$10$KFOdndCeV184iBdJpcQ6xet13mpLaTZLXf/rk/EplB1zISvkabjki', NULL, 'vinh', NULL, 1, '2025-09-09 15:33:29', '2025-09-21 16:45:48', NULL, 0),
(7, 'Nguyen Huy Quang', 'test1@gmail.com', '0886922226', '$2y$10$mEQDnpn8bWNUdksMQLa2W.HQnL4cBMI1N/f4oCzboeP6wbLi/hcSC', NULL, 'Tan binh ', NULL, 0, '2025-09-12 16:52:22', '2025-09-26 09:41:09', NULL, 0),
(8, 'Nguyen Huy Quang', 'huyquang1@gmail.com', '0886922226', '$2y$10$V40V08ea9cKAZNn2/Iemc.p.OldkgAo1Z5bqMPg/7ig22fiiOeQm2', NULL, 'Tan binh ', NULL, 0, '2025-09-13 09:09:16', '2025-09-26 09:41:21', NULL, 0),
(9, 'Nguyen quangn', 'test3@gmail.com', '0886922226', '$2y$10$tGvoX6thqd2QVCORoKcJE.VOFj5mypMdOjemIc7YwUfqU9m1K9Nmi', NULL, 'Tbinh', NULL, 1, '2025-09-16 16:47:30', '2025-09-16 16:47:30', NULL, 0),
(10, 'Quang Huy Nguyennnnnn', 'test5@gmail.com', '0886924681', '$2y$10$HKSE45ynh5nKpuXbmqI.geg0xbDftMk3on7DYSXEwbyWVgJs7AERS', NULL, 'Vinh,Nghe Annnnnn', NULL, 1, '2025-09-20 14:57:24', '2025-09-20 14:57:24', NULL, 0),
(11, 'Quang Huy Nguyen', 'hquang6504@gmail.com', '0886924681', '$2y$10$Ho47VGBZViREKUhA.tjRHuR0nKwyANfkb5J/rmCcgQ/Ditvuu1hXi', NULL, 'Vinh,Nghe An', NULL, 1, '2025-09-25 15:52:20', '2025-09-26 10:22:05', NULL, 0);

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
