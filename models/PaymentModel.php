<?php
require_once 'utils/Database.php';

if (!defined('PAYPAL_CLIENT_ID')) define('PAYPAL_CLIENT_ID', 'AXXLoiJNISpDX2Hu5A8w3_cCqKtMHr4uPdTjkVsmR57wkrPEpc9OpyuvJ63DdhyYT-bG8QUuGsH0yAlT');
if (!defined('PAYPAL_SECRET')) define('PAYPAL_SECRET', 'EC-SGIDSyuHFQfEfRcHCO-gQXgNY7ON2_VvxHVlqCMoZqh82nrG1zrrjVn0xMaw8338dfdvpvW3ffDrv');

class PaymentModel {
    private $db;
    public function __construct() {
        $this->db = (new Database())->getConnection();
    }

    // COD: lưu payment_method = cod, status = confirmed, but payment_status remains 'pending'
    // COD: payment_status = pending
public function processCOD($order_id, $user_id) {
    $stmt = $this->db->prepare("UPDATE Orders 
        SET payment_method='cod', status='confirmed', payment_status='pending' 
        WHERE id=? AND user_id=?");
    return $stmt->execute([$order_id, $user_id]);
}

// Momo giả lập -> mark paid
public function createMomoPayment($order_id, $user_id) {
    $this->db->beginTransaction();
    try {
        $stmt = $this->db->prepare("SELECT * FROM Orders WHERE id=? AND user_id=?");
        $stmt->execute([$order_id, $user_id]);
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$order) throw new Exception("Order not found");

        $tx = 'MOMO_' . time() . '_' . $order_id;
        $stmt = $this->db->prepare("UPDATE Orders 
            SET payment_method='momo', momo_transaction_id=?, 
                payment_status='paid', status='confirmed', payment_date=NOW() 
            WHERE id=?");
        $stmt->execute([$tx, $order_id]);

        $this->createPaymentRecord([
            'order_id' => $order_id,
            'payment_method' => 'momo',
            'amount' => $order['total'],
            'status' => 'paid',
            'transaction_id' => $tx
        ]);

        $this->db->commit();
        return ['success' => true, 'order_id' => $order_id, 'transaction_id' => $tx];
    } catch (Exception $e) {
        $this->db->rollBack();
        throw $e;
    }
}


    // Create PayPal order (calls sandbox API) => return approval_url + paypal_order_id
    public function createPaypalPayment($order_id, $user_id) {
        // fetch order
        $stmt = $this->db->prepare("SELECT * FROM Orders WHERE id=? AND user_id=?");
        $stmt->execute([$order_id, $user_id]);
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$order) throw new Exception("Order not found");

        // get access token
        $accessToken = $this->getPaypalAccessToken();

        // build payload (convert VND -> USD; adjust rate accordingly)
        $usd = round(($order['total'] / 23000), 2);
        if ($usd <= 0) $usd = "0.01";

        $returnUrl = "http://localhost/ecommerce_api/index.php/api/payment/paypal-success?order_id={$order_id}";
        $cancelUrl = "http://localhost/ecommerce_api/index.php/api/payment/paypal-cancel?order_id={$order_id}";

        $payload = [
            "intent" => "CAPTURE",
            "purchase_units" => [[
                "amount" => [
                    "currency_code" => "USD",
                    "value" => number_format($usd, 2, '.', '')
                ],
                "description" => "Order #{$order_id}"
            ]],
            "application_context" => [
                "return_url" => $returnUrl,
                "cancel_url" => $cancelUrl
            ]
        ];

        $ch = curl_init("https://api-m.sandbox.paypal.com/v2/checkout/orders");
        curl_setopt_array($ch, [
            CURLOPT_HTTPHEADER => [
                "Content-Type: application/json",
                "Authorization: Bearer $accessToken"
            ],
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_RETURNTRANSFER => true
        ]);
        $res = json_decode(curl_exec($ch), true);
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if (!$res || empty($res['id'])) {
            throw new Exception("PayPal create order failed: " . json_encode($res));
        }

        // lưu paypal_order_id tạm vào orders
        $paypalOrderId = $res['id'];
        $stmt = $this->db->prepare("UPDATE Orders SET payment_method='paypal', paypal_order_id=?, payment_status='pending' WHERE id=?");
        $stmt->execute([$paypalOrderId, $order_id]);

        // tìm link approve
        $approval = null;
        if (!empty($res['links'])) {
            foreach ($res['links'] as $l) {
                if ($l['rel'] === 'approve') { $approval = $l['href']; break; }
            }
        }
        if (!$approval) throw new Exception("Approval URL not found in PayPal response");

        return ['payment_url' => $approval, 'paypal_order_id' => $paypalOrderId, 'order_id' => $order_id, 'amount' => $order['total']];
    }

    // PayPal success: capture order and update DB
   public function processPaypalSuccess($order_id, $paypal_order_id) {
    if (!$order_id || !$paypal_order_id) throw new Exception("Missing params");

    $accessToken = $this->getPaypalAccessToken();

    // gọi API capture
    $ch = curl_init("https://api-m.sandbox.paypal.com/v2/checkout/orders/{$paypal_order_id}/capture");
    curl_setopt_array($ch, [
        CURLOPT_HTTPHEADER => [
            "Content-Type: application/json",
            "Authorization: Bearer $accessToken"
        ],
        CURLOPT_CUSTOMREQUEST => "POST",
        CURLOPT_POSTFIELDS => "{}", // body rỗng nhưng vẫn cần
        CURLOPT_RETURNTRANSFER => true
    ]);
    $res = json_decode(curl_exec($ch), true);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($code != 201 || empty($res['status'])) {
        throw new Exception("Capture failed: " . json_encode($res));
    }

    if ($res['status'] === 'COMPLETED') {
        // cập nhật order
        $this->db->beginTransaction();
        try {
            $stmt = $this->db->prepare("SELECT total FROM Orders WHERE id=?");
            $stmt->execute([$order_id]);
            $order = $stmt->fetch(PDO::FETCH_ASSOC);
            $amount = $order ? $order['total'] : 0;

            $stmt = $this->db->prepare("UPDATE Orders 
                SET payment_status='paid', status='confirmed', payment_date=NOW(), paypal_order_id=? 
                WHERE id=?");
            $stmt->execute([$paypal_order_id, $order_id]);

            $this->createPaymentRecord([
                'order_id' => $order_id,
                'payment_method' => 'paypal',
                'amount' => $amount,
                'status' => 'paid',
                'transaction_id' => $paypal_order_id
            ]);

            $this->db->commit();
            return true;
        } catch (Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    } else {
        return false;
    }
}
// Trong PaymentModel.php
public function getOrderIdByPaypalOrder($paypal_order_id) {
    $stmt = $this->db->prepare("SELECT id FROM orders WHERE paypal_order_id = ?");
    $stmt->execute([$paypal_order_id]);
    return $stmt->fetchColumn();
}
public function capturePaypalPayment($order_id, $paypal_order_id) {
    $accessToken = $this->getPaypalAccessToken();

    $ch = curl_init("https://api-m.sandbox.paypal.com/v2/checkout/orders/{$paypal_order_id}/capture");
    curl_setopt_array($ch, [
        CURLOPT_HTTPHEADER => [
            "Content-Type: application/json",
            "Authorization: Bearer $accessToken"
        ],
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true
    ]);
    $res = json_decode(curl_exec($ch), true);
    curl_close($ch);

    if (empty($res['status']) || $res['status'] !== 'COMPLETED') {
        return false;
    }

    // cập nhật DB
    $this->db->beginTransaction();
    try {
        $stmt = $this->db->prepare("SELECT total FROM orders WHERE id=?");
        $stmt->execute([$order_id]);
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        $amount = $order ? $order['total'] : 0;

        $stmt = $this->db->prepare("UPDATE orders 
            SET payment_status='paid', status='confirmed', payment_date=NOW() 
            WHERE id=? AND paypal_order_id=?");
        $stmt->execute([$order_id, $paypal_order_id]);

        $this->createPaymentRecord([
            'order_id' => $order_id,
            'payment_method' => 'paypal',
            'amount' => $amount,
            'status' => 'paid',
            'transaction_id' => $paypal_order_id
        ]);

        $this->db->commit();
        return true;
    } catch (Exception $e) {
        $this->db->rollBack();
        throw $e;
    }
}



    public function processPaypalCancel($order_id, $paypal_order_id) {
        if (!$order_id) return false;
        $stmt = $this->db->prepare("UPDATE Orders SET payment_status='failed', status='pending' WHERE id=?");
        return $stmt->execute([$order_id]);
    }

    // helper: get paypal token
    private function getPaypalAccessToken() {
        $ch = curl_init("https://api-m.sandbox.paypal.com/v1/oauth2/token");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_USERPWD, PAYPAL_CLIENT_ID . ":" . PAYPAL_SECRET);
        curl_setopt($ch, CURLOPT_POSTFIELDS, "grant_type=client_credentials");
        curl_setopt($ch, CURLOPT_HTTPHEADER, ["Accept: application/json"]);
        $res = json_decode(curl_exec($ch), true);
        curl_close($ch);
        if (empty($res['access_token'])) throw new Exception("Cannot get PayPal access token");
        return $res['access_token'];
    }

    // ghi record vào payments table
    private function createPaymentRecord($payment_data) {
        $stmt = $this->db->prepare("INSERT INTO payments (order_id, payment_method, amount, status, transaction_id, created_at) VALUES (:order_id, :payment_method, :amount, :status, :transaction_id, NOW())");
        return $stmt->execute([
            ':order_id' => $payment_data['order_id'],
            ':payment_method' => $payment_data['payment_method'],
            ':amount' => $payment_data['amount'],
            ':status' => $payment_data['status'],
            ':transaction_id' => $payment_data['transaction_id']
        ]);
    }
}
?>
