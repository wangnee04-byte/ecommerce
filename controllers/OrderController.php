<?php
require_once 'models/OrderModel.php';
require_once 'utils/Response.php';
require_once 'middleware/ValidationMiddleware.php';
require_once 'models/PaymentModel.php';
require_once 'middleware/RBACMiddleware.php';

class OrderController {
    private $orderModel;
    private $validator;
    private $paymentModel;
    private $rbac;

    public function __construct() {
        $this->orderModel = new OrderModel();
        $this->validator = new ValidationMiddleware();
        $this->paymentModel = new PaymentModel();
        $this->rbac = new RBACMiddleware();
    }

    // POST /api/orders
    public function createOrder($params, $user_data) {
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data || empty($data['items'])) {
            Response::sendError("Items required", 400);
        }
        $userId = $user_data['user_id'] ?? null;
        if (!$userId) Response::sendError("Unauthorized", 401);

        try {
            $orderId = $this->orderModel->createOrder($userId, $data);
            Response::sendSuccess(['order_id' => $orderId], "Order created (pending)");
        } catch (Exception $e) {
            Response::sendError("Failed to create order: " . $e->getMessage(), 500);
        }
    }

    // GET /api/orders
    public function getOrders($params, $user_data) {
        try {
            if ($this->isAdmin($user_data)) {
                $orders = $this->orderModel->getAllOrders();
            } else {
                $orders = $this->orderModel->getOrders(['user_id' => $user_data['user_id']]);
            }
            Response::sendSuccess($orders, "Orders fetched");
        } catch (Exception $e) {
            Response::sendError("Error fetching orders: " . $e->getMessage(), 500);
        }
    }
     public function userUpdateOrder($params, $body) {
    $orderId = $params[0] ?? null;
    $actor   = $body['actor'] ?? 'user';

    if (!$orderId) {
        http_response_code(400);
        echo json_encode(['error' => 'Thiếu ID đơn hàng']);
        return;
    }

    // Lấy thông tin đơn hàng
    $order = $this->orderModel->getOrderById($orderId);
    if (!$order) {
        http_response_code(404);
        echo json_encode(['error' => 'Không tìm thấy đơn hàng']);
        return;
    }

    // Nếu chưa thanh toán → hủy ngay
    if ($order['payment_status'] === 'pending') {
        $ok = $this->orderModel->userCancelOrder($orderId, $order['user_id']);
        if ($ok) {
            echo json_encode([
                'success' => true,
                'message' => "Đơn #$orderId đã bị hủy (pending → failed)",
                'actor'   => $actor
            ]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Không thể hủy đơn hàng']);
        }
        return;
    }

    // Nếu đã thanh toán → gửi yêu cầu hủy
    if ($order['payment_status'] === 'paid') {
        $ok = $this->orderModel->updateOrderStatus($orderId, 'cancel_request');
        if ($ok) {
            echo json_encode([
                'success' => true,
                'message' => "Đã gửi yêu cầu hủy đơn #$orderId",
                'actor'   => $actor
            ]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Không thể gửi yêu cầu hủy']);
        }
        return;
    }

    // Trạng thái khác → không cho hủy
    http_response_code(400);
    echo json_encode(['error' => 'Trạng thái thanh toán không thể hủy']);
}


    // GET /api/orders/user/{id}
    public function getUserOrders($params, $user_data) {
        $user_id = $params[0] ?? null;
        if (!$user_id) Response::sendError("User ID required", 400);

        if ($user_data['user_id'] != $user_id && !$this->isAdmin($user_data)) {
            Response::sendError("Access denied", 403);
        }

        try {
            $filters = ['user_id' => $user_id];
            if (isset($_GET['status'])) $filters['status'] = $_GET['status'];
            $orders = $this->orderModel->getOrders($filters);
            Response::sendSuccess($orders);
        } catch (Exception $e) {
            Response::sendError("Error retrieving user orders: " . $e->getMessage(), 500);
        }
    }

    // GET /api/orders/{id}
    public function getOrderById($params, $user_data) {
        $id = $params[0] ?? null;
        if (!$id) Response::sendError("Order ID required", 400);

        try {
            $order = $this->orderModel->getOrderById($id, $user_data['user_id']);
            if (!$order) Response::sendError("Order not found", 404);

            if ($order['user_id'] != $user_data['user_id'] && !$this->isAdmin($user_data)) {
                Response::sendError("Access denied", 403);
            }

            Response::sendSuccess($order);
        } catch (Exception $e) {
            Response::sendError("Error retrieving order: " . $e->getMessage(), 500);
        }
    }

    // PUT /api/orders/{id}
    public function updateOrder($params, $user_data) {
        $orderId = $params[0] ?? null;
        if (!$orderId) Response::sendError("Order ID required", 400);

        $userId = $user_data['user_id'] ?? null;
        if (!$userId) Response::sendError("Unauthorized", 401);

        $data = json_decode(file_get_contents("php://input"), true);

        try {
            if (isset($data['cancel']) && $data['cancel'] === true) {
                $order = $this->orderModel->getOrderById($orderId, $userId);
                if (!$order) Response::sendError("Order not found", 404);

                if ($order['payment_status'] === 'pending') {
                    $ok = $this->orderModel->userCancelOrder($orderId, $userId);
                    if ($ok) {
                        Response::sendSuccess(true, "Đơn hàng đã được hủy (chưa thanh toán)");
                    } else {
                        Response::sendError("Không thể hủy đơn hàng");
                    }
                } elseif ($order['payment_status'] === 'paid') {
                    $ok = $this->orderModel->requestCancel($orderId, $userId);
                    if ($ok) {
                        Response::sendSuccess(true, "Yêu cầu hủy đơn đã được gửi, chờ admin xác nhận");
                    } else {
                        Response::sendError("Không thể gửi yêu cầu hủy");
                    }
                } else {
                    Response::sendError("Không thể hủy đơn ở trạng thái thanh toán này");
                }
                return;
            }

            $ok = $this->orderModel->updateShippingInfo($orderId, $userId, $data);
            if ($ok) {
                Response::sendSuccess(true, "Cập nhật thông tin giao hàng thành công");
            } else {
                Response::sendError("Cập nhật thất bại");
            }
        } catch (Exception $e) {
            Response::sendError("Error: " . $e->getMessage(), 500);
        }
    }

    // PUT /api/orders/{id}/status
    public function updateOrderStatus($params, $user_data) {
        $id = $params[0] ?? null;
        if (!$id) Response::sendError("Order ID required", 400);

        if (!$this->isAdmin($user_data)) Response::sendError("Access denied", 403);

        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['status'])) Response::sendError("Status is required", 400);

        try {
            $success = $this->orderModel->updateOrderStatus($id, $data['status']);
            if ($success) {
                Response::sendSuccess([], "Order status updated successfully");
            } else {
                Response::sendError("Failed to update order status");
            }
        } catch (Exception $e) {
            Response::sendError("Error updating order status: " . $e->getMessage(), 500);
        }
    }

    // PUT /api/orders/{order_id}/confirm
    public function confirmOrder($params, $user_data) {
        $orderId = $params[0] ?? null;
        if (!$orderId) Response::sendError("Order ID required", 400);

        $userId = $user_data['user_id'] ?? null;
        if (!$userId) Response::sendError("Unauthorized", 401);

        $data = json_decode(file_get_contents("php://input"), true);

        try {
            $ok = $this->orderModel->confirmOrder($orderId, $userId, $data);
            if ($ok) {
                Response::sendSuccess(true, "Order confirmed");
            } else {
                Response::sendError("Update failed");
            }
        } catch (Exception $e) {
            Response::sendError("Error: " . $e->getMessage(), 500);
        }
    }
 
// ...existing code...
    public function cancelOrder($params, $user_data) {
        $orderId = $params[0] ?? null;
        if (!$orderId) Response::sendError("Order ID required", 400);

        $currentUserId = $user_data['user_id'] ?? null;
        if (!$currentUserId) Response::sendError("Unauthorized", 401);

        try {
            // Fetch order without restrictive user filter to check ownership
            $order = $this->orderModel->getOrderById($orderId, $currentUserId);
            if (!$order) {
                // maybe the order exists but belongs to someone else
                // try to fetch order only by id
                $order = $this->orderModel->getOrderById($orderId, $order ? $order['user_id'] : $currentUserId);
            }
            if (!$order) Response::sendError("Order not found", 404);

            // Admin path: if user has admin role, allow admin cancel via this endpoint too
            if ($this->isAdmin($user_data)) {
                $ok = $this->orderModel->adminCancelOrder($orderId);
                if ($ok) {
                    Response::sendSuccess(true, "Đã hủy đơn hàng (admin)");
                } else {
                    Response::sendError("Hủy đơn thất bại");
                }
                return;
            }

            // Owner can cancel only if they own the order and it's pending
            if ($order['user_id'] == $currentUserId) {
                if ($order['payment_status'] === 'pending' ) {
                    $ok = $this->orderModel->userCancelOrder($orderId, $currentUserId);
                    if ($ok) {
                        Response::sendSuccess(true, "Đã hủy đơn hàng");
                    } else {
                        Response::sendError("Không thể hủy đơn hàng");
                    }
                    return;
                }

                // If already paid, user can send a cancel request (handled elsewhere)
                if ($order['payment_status'] === 'paid') {
                    $ok = $this->orderModel->requestCancel($orderId, $currentUserId);
                    if ($ok) {
                        Response::sendSuccess(true, "Yêu cầu hủy đơn đã được gửi, chờ admin xác nhận");
                    } else {
                        Response::sendError("Không thể gửi yêu cầu hủy");
                    }
                    return;
                }
            }

            Response::sendError("Bạn chỉ có thể hủy đơn của mình khi đang chờ xử lý", 403);
        } catch (Exception $e) {
            Response::sendError("Error: " . $e->getMessage(), 500);
        }
    }
// ...existing code...


    // PUT /api/orders/{id}/cancel (admin duyệt hủy)
    public function adminCancelOrder($params, $user_data) {
        if (!$this->isAdmin($user_data)) Response::sendError("Access denied", 403);

        $orderId = $params[0] ?? null;
        if (!$orderId) Response::sendError("Order ID required", 400);

        try {
            $ok = $this->orderModel->adminCancelOrder($orderId);
            if ($ok) {
                Response::sendSuccess(true, "Đơn hàng đã bị hủy (admin duyệt)");
            } else {
                Response::sendError("Hủy đơn thất bại (kiểm tra trạng thái)");
            }
        } catch (Exception $e) {
            Response::sendError("Error: " . $e->getMessage(), 500);
        }
    }

    // check quyền admin
    private function isAdmin($user_data) {
        return in_array('super_admin', $user_data['roles']) ||
               in_array('order_admin', $user_data['roles']);
    }
}
