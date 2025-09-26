<?php
require_once 'models/PaymentModel.php';
require_once 'utils/Response.php';
require_once 'middleware/RBACMiddleware.php';

class PaymentController {
    private $paymentModel;
    private $rbac;

    public function __construct() {
        $this->paymentModel = new PaymentModel();
        $this->rbac = new RBACMiddleware();
    }

    // ================== COD ==================
public function processCOD($params, $user_data) {
    try {
        $order_id = $params[0] ?? null;
        if (!$order_id) {
            Response::sendError('Order ID is required', 400);
        }

        if (!$this->rbac->checkPermission($user_data['user_id'], 'order.create')) {
            Response::sendError('Insufficient permissions', 403);
        }

        if ($this->paymentModel->processCOD($order_id, $user_data['user_id'])) {
            // ✅ trả redirect_url để FE xử lý như PayPal
            Response::sendSuccess([
                "redirect_url" => "http://127.0.0.1:5500/test%20html/cart.html?status=success&order_id={$order_id}"
            ], "COD order confirmed");
        } else {
            Response::sendError("Thanh toán COD thất bại", 400);
        }
    } catch (Exception $e) {
        Response::sendError($e->getMessage(), 500);
    }
}



    // ================== MOMO ==================
  public function createMomoPayment($params, $user_data) {
    try {
        $order_id = $params[0] ?? null;
        if (!$order_id) {
            Response::sendError('Order ID is required', 400);
        }

        if (!$this->rbac->checkPermission($user_data['user_id'], 'order.create')) {
            Response::sendError('Insufficient permissions', 403);
        }

        $result = $this->paymentModel->createMomoPayment($order_id, $user_data['user_id']);
        if ($result) {
            // ✅ giống COD → trả redirect_url về cart
            Response::sendSuccess([
                "redirect_url" => "http://127.0.0.1:5500/test%20html/cart.html?status=success&order_id={$order_id}"
            ], "Momo payment success");
        } else {
            Response::sendError("Momo payment failed", 400);
        }
    } catch (Exception $e) {
        Response::sendError($e->getMessage(), 500);
    }
}


    public function processMomoCallback($params, $user_data) {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (empty($data)) {
                $data = [
                    'transactionId' => $_GET['transactionId'] ?? null,
                    'resultCode' => $_GET['resultCode'] ?? 0,
                    'amount' => $_GET['amount'] ?? 0
                ];
            }

            if (empty($data['transactionId'])) {
                Response::sendError('Transaction ID is required', 400);
            }

            $result = $this->paymentModel->processMomoCallback($data);
            if ($result['success']) {
                Response::sendSuccess([
                    'order_id' => $result['order_id'],
                    'transaction_id' => $result['transaction_id'],
                    'status' => 'paid'
                ], 'Momo payment processed successfully');
            } else {
                Response::sendError('Momo payment failed', 400);
            }
        } catch (Exception $e) {
            Response::sendError('Error processing Momo callback: ' . $e->getMessage());
        }
    }

    // ================== PAYPAL ==================
    public function createPaypalPayment($params, $user_data) {
        try {
            $order_id = $params[0] ?? null;
            if (!$order_id) {
                Response::sendError('Order ID is required', 400);
            }

            if (!$this->rbac->checkPermission($user_data['user_id'], 'order.create')) {
                Response::sendError('Insufficient permissions', 403);
            }

            $result = $this->paymentModel->createPaypalPayment($order_id, $user_data['user_id']);
            if ($result) {
                Response::sendSuccess($result, 'Paypal payment initiated successfully');
            } else {
                Response::sendError('Failed to create Paypal payment');
            }
        } catch (Exception $e) {
            Response::sendError('Error creating Paypal payment: ' . $e->getMessage());
        }
    }

  public function processPaypalSuccess($params, $user_data) {
    try {
        $paypal_order_id = $_GET['paypal_order_id'] ?? ($_GET['token'] ?? null);

        if (!$paypal_order_id) {
            Response::sendError('Paypal token is required', 400);
        }

        // lấy order_id từ DB
        $order_id = $this->paymentModel->getOrderIdByPaypalOrder($paypal_order_id);
        if (!$order_id) {
            Response::sendError('Order not found for this PayPal order', 404);
        }

        $result = $this->paymentModel->capturePaypalPayment($order_id, $paypal_order_id);

        if ($result) {
            // Redirect về trang giỏ hàng + truyền query string báo thành công
            $redirectUrl = "http://127.0.0.1:5500/test%20html/cart.html?status=success&order_id={$order_id}";
            header("Location: $redirectUrl");
            exit;
        } else {
            $redirectUrl = "http://127.0.0.1:5500/test%20html/cart.html?status=failed&order_id={$order_id}";
            header("Location: $redirectUrl");
            exit;
        }
    } catch (Exception $e) {
        $redirectUrl = "http://127.0.0.1:5500/test%20html/cart.html?status=failed&error=" . urlencode($e->getMessage());
        header("Location: $redirectUrl");
        exit;
    }
}




    public function processPaypalCancel($params, $user_data) {
        try {
            $order_id = $_GET['order_id'] ?? null;
            $paypal_order_id = $_GET['paypal_order_id'] ?? null;

            if (!$order_id || !$paypal_order_id) {
                Response::sendError('Order ID and PayPal Order ID are required', 400);
            }

            $result = $this->paymentModel->processPaypalCancel($order_id, $paypal_order_id);
            if ($result) {
                Response::sendSuccess([
                    'order_id' => $order_id,
                    'paypal_order_id' => $paypal_order_id,
                    'status' => 'failed'
                ], 'Paypal payment canceled');
            } else {
                Response::sendError('Failed to process Paypal cancel');
            }
        } catch (Exception $e) {
            Response::sendError('Error processing Paypal cancel: ' . $e->getMessage());
        }
    }

    // ================== CHECK STATUS ==================
    public function checkPaymentStatus($params, $user_data) {
        try {
            $order_id = $params[0] ?? null;
            if (!$order_id) {
                Response::sendError('Order ID is required', 400);
            }

            if (!$this->rbac->checkPermission($user_data['user_id'], 'order.read')) {
                Response::sendError('Insufficient permissions', 403);
            }

            $status = $this->paymentModel->checkPaymentStatus($order_id, $user_data['user_id']);
            if ($status) {
                Response::sendSuccess($status, 'Payment status retrieved successfully');
            } else {
                Response::sendError('Payment status not found', 404);
            }
        } catch (Exception $e) {
            Response::sendError('Error checking payment status: ' . $e->getMessage());
        }
    }
}
