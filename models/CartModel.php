<?php
require_once 'utils/Database.php';

class CartModel {
    private $db;
    
    public function __construct() {
        $this->db = (new Database())->getConnection();
    }
    
    public function getCart($user_id) {
        // Get or create cart for user
        $cart = $this->getUserCart($user_id);
        
        if (!$cart) {
            $cart_id = $this->createCart($user_id);
        } else {
            $cart_id = $cart['id'];
        }
        
        // Get cart items
        $query = "SELECT ci.*, p.product_name, p.price, p.thumbnail 
                  FROM Cart_Items ci 
                  JOIN Product p ON ci.product_id = p.id 
                  WHERE ci.cart_id = :cart_id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':cart_id', $cart_id);
        $stmt->execute();
        
        $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Calculate total
        $total = 0;
        foreach ($items as $item) {
            $total += $item['price'] * $item['quantity'];
        }
        
        return [
            'cart_id' => $cart_id,
            'items' => $items,
            'total' => $total
        ];
    }
    
    public function getUserCart($user_id) {
        $query = "SELECT * FROM Cart WHERE user_id = :user_id ORDER BY created_at DESC LIMIT 1";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    public function createCart($user_id) {
        $query = "INSERT INTO Cart (user_id) VALUES (:user_id)";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        
        return $this->db->lastInsertId();
    }
    
    public function addToCart($cart_id, $product_id, $quantity) {
        // Check if product already in cart
        $query = "SELECT * FROM Cart_Items WHERE cart_id = :cart_id AND product_id = :product_id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':cart_id', $cart_id);
        $stmt->bindParam(':product_id', $product_id);
        $stmt->execute();
        
        $existingItem = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existingItem) {
            // Update quantity
            $newQuantity = $existingItem['quantity'] + $quantity;
            return $this->updateCartItem($existingItem['id'], $newQuantity);
        } else {
            // Add new item
            $query = "INSERT INTO Cart_Items (cart_id, product_id, quantity) 
                      VALUES (:cart_id, :product_id, :quantity)";
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':cart_id', $cart_id);
            $stmt->bindParam(':product_id', $product_id);
            $stmt->bindParam(':quantity', $quantity);
            
            return $stmt->execute();
        }
    }
    
    public function updateCartItem($item_id, $quantity) {
        if ($quantity <= 0) {
            return $this->removeFromCart($item_id);
        }
        
        $query = "UPDATE Cart_Items SET quantity = :quantity WHERE id = :id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':id', $item_id);
        $stmt->bindParam(':quantity', $quantity);
        
        return $stmt->execute();
    }
    
    public function removeFromCart($item_id) {
        $query = "DELETE FROM Cart_Items WHERE id = :id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':id', $item_id);
        
        return $stmt->execute();
    }
    
    public function clearCart($cart_id) {
        $query = "DELETE FROM Cart_Items WHERE cart_id = :cart_id";
        
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':cart_id', $cart_id);
        
        return $stmt->execute();
    }
}