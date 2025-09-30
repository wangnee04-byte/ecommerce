<?php
require_once 'models/UserModel.php';
require_once 'utils/Response.php';
require_once 'middleware/ValidationMiddleware.php';

class UserController {
    private $userModel;
    private $validator;
    
    public function __construct() {
        $this->userModel = new UserModel();
        $this->validator = new ValidationMiddleware();
    }
    
    public function getUsers($params, $user_data) {
        try {
            $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
            $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
            
            $users = $this->userModel->getUsers($page, $limit);
            
            Response::sendSuccess($users);
        } catch (Exception $e) {
            Response::sendError('Error retrieving users: ' . $e->getMessage());
        }
    }
    
    public function getUserById($params, $user_data) {
        try {
            $id = $params[0];
            
            // Users can only view their own profile unless they're admin
            if ($user_data['user_id'] != $id && !$this->isAdmin($user_data)) {
                Response::sendError('Access denied', 403);
            }
            
            $user = $this->userModel->getUserById($id);
            
            if ($user) {
                Response::sendSuccess($user);
            } else {
                Response::sendError('User not found', 404);
            }
        } catch (Exception $e) {
            Response::sendError('Error retrieving user: ' . $e->getMessage());
        }
    }
    
 public function updateUser($params, $user_data) {
    try {
        $id = $params[0];
        
        // Chỉ cho user tự update hoặc admin
        if ($user_data['user_id'] != $id && !$this->isAdmin($user_data)) {
            Response::sendError('Access denied', 403);
        }
        
        $data = json_decode(file_get_contents('php://input'), true);
        
        $user = $this->userModel->getUserById($id);
        if (!$user) {
            Response::sendError('User not found', 404);
        }

        // Nếu có password mới thì validate
        if (!empty($data['password'])) {
            // Validate + hash như hiện tại
            $validator = new Validator();
            $errors = $validator->validatePasswordOnly($data['password']);


            if (!empty($errors)) {
                Response::sendError('Validation failed', 400, $errors);
            }

            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);

            // Ghi nhận đã đổi mật khẩu (không reset verify)
            $this->userModel->savePasswordChangeLog($id);

            // Gửi email thông báo đổi mật khẩu
            require_once 'controllers/AuthController.php';
            $auth = new AuthController();
            $auth->sendPasswordChangedEmail($user['email']); // cần tạo thêm hàm này trong AuthController
        }


        $success = $this->userModel->updateUser($id, $data);
        
        if ($success) {
            Response::sendSuccess([], 'User updated successfully');
        } else {
            Response::sendError('Failed to update user');
        }
    } catch (Exception $e) {
        Response::sendError('Error updating user: ' . $e->getMessage());
    }
}



    
    public function deleteUser($params, $user_data) {
        try {
            $id = $params[0];
            
            // Users cannot delete themselves, only admins can delete users
            if (!$this->isAdmin($user_data)) {
                Response::sendError('Access denied', 403);
            }
            
            if ($user_data['user_id'] == $id) {
                Response::sendError('Cannot delete your own account', 400);
            }
            
            $user = $this->userModel->getUserById($id);
            if (!$user) {
                Response::sendError('User not found', 404);
            }
            
            $success = $this->userModel->deleteUser($id);
            
            if ($success) {
                Response::sendSuccess([], 'User deleted successfully');
            } else {
                Response::sendError('Failed to delete user');
            }
        } catch (Exception $e) {
            Response::sendError('Error deleting user: ' . $e->getMessage());
        }
    }
    
    private function isAdmin($user_data) {
        return in_array('super_admin', $user_data['roles']) || 
               in_array('product_admin', $user_data['roles']) || 
               in_array('order_admin', $user_data['roles']) || 
               in_array('content_admin', $user_data['roles']) || 
               in_array('report_admin', $user_data['roles']);
    }
    public function getCurrentUser($params, $user_data) {
    try {
        // Lấy user_id từ dữ liệu xác thực (middleware đã decode token)
        $id = $user_data['user_id'];

        $user = $this->userModel->getUserById($id);
        if ($user) {
            // Trả về thông tin cơ bản cần dùng ở payment.html
            Response::sendSuccess([
                'full_name' => $user['full_name'] ?? '',
                'phone'     => $user['phone'] ?? '',
                'address'   => $user['address'] ?? ''
            ]);
        } else {
            Response::sendError('User not found', 404);
        }
    } catch (Exception $e) {
        Response::sendError('Error retrieving current user: ' . $e->getMessage());
    }
}

}