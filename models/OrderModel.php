<?php
require_once 'utils/Database.php';

class OrderModel {
    private $conn;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // ================= TẠO ĐƠN HÀNG =================
    public function createOrder($userId, $data) {
        $items = $data['items'];
        $payment_method = $data['payment_method'] ?? null;
        $total = $data['total'] ?? 0;

        $this->conn->beginTransaction();
        try {
            $stmt = $this->conn->prepare("
    INSERT INTO orders (
        user_id, fullname, email, phone, address, total,
        payment_method, payment_status, status, created_at
    ) VALUES (
        :user_id, :fullname, :email, :phone, :address, :total,
        :payment_method, 'pending', 'pending', NOW()
    )
");
$stmt->execute([
    ':user_id' => $userId,
    ':fullname' => $data['fullname'] ?? '',
    ':email' => $data['email'] ?? '',
    ':phone' => $data['phone'] ?? '',
    ':address' => $data['address'] ?? '',
    ':total' => $total,
    ':payment_method' => $payment_method
            ]);
            $orderId = $this->conn->lastInsertId();

            $stmtItem = $this->conn->prepare("
                INSERT INTO order_details (order_id, product_id, price, quantity)
                VALUES (:order_id, :product_id, :price, :quantity)
            ");
            foreach ($items as $it) {
                $stmtItem->execute([
                    ':order_id' => $orderId,
                    ':product_id' => $it['product_id'],
                    ':price' => $it['price'],
                    ':quantity' => $it['quantity']
                ]);
            }

            $this->conn->commit();
            return $orderId;
        } catch (Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }

    // ================= LẤY CHI TIẾT ĐƠN HÀNG THEO ID =================
    public function getOrderById($orderId, $userId = null) {
        $query = "SELECT id, user_id, fullname, email, phone, address, total,
                         payment_method, payment_status, status, paypal_transaction_id,
                         momo_transaction_id, created_at
                  FROM orders
                  WHERE id = :id";
        $params = [':id' => $orderId];
        if ($userId !== null) {
            $query .= " AND user_id = :user_id";
            $params[':user_id'] = $userId;
        }

        $stmt = $this->conn->prepare($query);
        $stmt->execute($params);
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$order) return null;

        $stmt2 = $this->conn->prepare("SELECT product_id, price, quantity FROM order_details WHERE order_id = :order_id");
        $stmt2->execute([':order_id' => $orderId]);
        $order['items'] = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        return $order;
    }

    // ================= LẤY DANH SÁCH ĐƠN =================
    public function getAllOrders() {
        $stmt = $this->conn->query("
            SELECT id, fullname, phone, address, payment_method,
                   payment_status, status, total, created_at
            FROM orders ORDER BY created_at DESC
        ");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getOrders($filters) {
        $query = "SELECT id, fullname, phone, address, payment_method,
                         payment_status, status, total, created_at
                  FROM orders WHERE 1=1";
        $params = [];
        if (!empty($filters['user_id'])) {
            $query .= " AND user_id = :user_id";
            $params[':user_id'] = $filters['user_id'];
        }
        $query .= " ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // ================= USER HỦY =================
    public function userCancelOrder($orderId, $userId) {
        $stmt = $this->conn->prepare("
            UPDATE orders
            SET status = 'cancelled', payment_status = 'failed', updated_at = NOW()
            WHERE id = :order_id AND user_id = :user_id AND payment_status = 'pending'
        ");
        return $stmt->execute([
            ':order_id' => $orderId,
            ':user_id' => $userId
        ]);
    }

    public function requestCancel($orderId, $userId) {
        $stmt = $this->conn->prepare("
            UPDATE orders
            SET status = 'cancel_request', updated_at = NOW()
            WHERE id = :order_id AND user_id = :user_id AND payment_status = 'paid'
        ");
        return $stmt->execute([
            ':order_id' => $orderId,
            ':user_id' => $userId
        ]);
    }

    // ================= ADMIN HỦY =================
    public function adminCancelOrder($orderId) {
        $stmt = $this->conn->prepare("
            UPDATE orders
            SET status = 'cancelled', payment_status = 'failed', updated_at = NOW()
            WHERE id = :order_id AND status = 'cancel_request' AND payment_status = 'paid'
        ");
        return $stmt->execute([':order_id' => $orderId]);
    }

    // ================= USER CẬP NHẬT SHIPPING =================
    public function updateShippingInfo($orderId, $userId, $data) {
        $stmt = $this->conn->prepare("
            UPDATE orders
            SET fullname = :fullname, phone = :phone, address = :address, updated_at = NOW()
            WHERE id = :order_id AND user_id = :user_id AND status = 'pending'
        ");
        return $stmt->execute([
            ':fullname' => $data['fullname'] ?? null,
            ':phone' => $data['phone'] ?? null,
            ':address' => $data['address'] ?? null,
            ':order_id' => $orderId,
            ':user_id' => $userId
        ]);
    }

    // ================= PAYPAL PAYMENT =================
    public function updatePaypalPayment($orderId, $paypalId, $payerEmail, $status) {
        $query = "UPDATE orders
                  SET paypal_transaction_id = :paypal_id,
                      paypal_payer_email = :payer_email,
                      payment_status = :status,
                      payment_date = NOW()
                  WHERE id = :order_id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':paypal_id' => $paypalId,
            ':payer_email' => $payerEmail,
            ':status' => $status,
            ':order_id' => $orderId
        ]);
    }

    // ================= XÓA ĐƠN =================
    public function deleteOrder($id) {
        $this->conn->beginTransaction();
        try {
            $stmt = $this->conn->prepare("DELETE FROM order_details WHERE order_id = :id");
            $stmt->execute([':id' => $id]);

            $stmt = $this->conn->prepare("DELETE FROM orders WHERE id = :id");
            $stmt->execute([':id' => $id]);

            $this->conn->commit();
            return true;
        } catch (Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }
     public function getDB() {
        return $this->conn;
    }
    public function confirmOrder($orderId, $userId, $data = []) {
    $db = $this->getDB();
    // Lấy đơn hàng
    $stmt = $db->prepare("SELECT * FROM orders WHERE id = ?");
    $stmt->execute([$orderId]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$order) return false;

    // Chỉ admin mới xác nhận hủy
    if ($order['status'] === 'cancel_request') {
        // Cập nhật trạng thái sang cancelled + failed
        $stmt = $db->prepare("UPDATE orders SET status = 'cancelled', payment_status = 'failed' WHERE id = ?");
        return $stmt->execute([$orderId]);
    }

    // Hoặc xác nhận thanh toán (tùy business logic)
    $stmt = $db->prepare("UPDATE orders SET status = 'confirmed' WHERE id = ?");
    return $stmt->execute([$orderId]);
}

// ================= CẬP NHẬT TRẠNG THÁI ĐƠN HÀNG =================
public function updateOrderStatus($orderId, $status) {
    $stmt = $this->conn->prepare("
        UPDATE orders
        SET status = :status, updated_at = NOW()
        WHERE id = :order_id
    ");
    return $stmt->execute([
        ':status'    => $status,
        ':order_id'  => $orderId
    ]);
}


}
