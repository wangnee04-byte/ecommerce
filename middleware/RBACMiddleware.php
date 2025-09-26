<?php
require_once 'utils/Database.php';

class RBACMiddleware {
    private $db;
    
    public function __construct() {
        $this->db = (new Database())->getConnection();
    }
    
    public function checkPermission($user_id, $required_permission) {
        // Kiểm tra super admin
        if ($this->isSuperAdmin($user_id)) {
            return true;
        }

        // "authenticated" permission: any authenticated user is allowed
        if ($required_permission === 'authenticated') {
            return $user_id !== null;
        }
        
        // Kiểm tra quyền cụ thể
        $query = "SELECT p.permission_name 
                  FROM User_Role ur 
                  JOIN Role_Permission rp ON ur.role_id = rp.role_id 
                  JOIN Permission p ON rp.permission_id = p.id 
                  WHERE ur.user_id = :user_id AND p.permission_name = :permission";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':permission', $required_permission);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }
    
    public function getUserRoles($user_id) {
        $query = "SELECT r.id, r.role_name, r.role_type 
                  FROM User_Role ur 
                  JOIN Roles r ON ur.role_id = r.id 
                  WHERE ur.user_id = :user_id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public function isSuperAdmin($user_id) {
        $query = "SELECT r.role_name 
                  FROM User_Role ur 
                  JOIN Roles r ON ur.role_id = r.id 
                  WHERE ur.user_id = :user_id AND r.role_name = 'super_admin'";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }
    
    public function isAdmin($user_id) {
        $roles = $this->getUserRoles($user_id);
        foreach ($roles as $role) {
            if ($role['role_type'] === 'full_admin' || $role['role_type'] === 'limited_admin') {
                return true;
            }
        }
        return false;
    }
    
    public function isCustomer($user_id) {
        $roles = $this->getUserRoles($user_id);
        foreach ($roles as $role) {
            if ($role['role_type'] === 'customer') {
                return true;
            }
        }
        return false;
    }
}