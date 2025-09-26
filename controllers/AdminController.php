<?php
require_once 'models/AdminModel.php';
require_once 'models/OrderModel.php';
require_once 'utils/Response.php';

class AdminController {
    private $adminModel;
    private $orderModel;
    
    public function __construct() {
        $this->adminModel = new AdminModel();
        $this->orderModel = new OrderModel();
    }
    
    public function getDashboard($params, $user_data) {
        try {
            $stats = $this->adminModel->getDashboardStats();
            
            Response::sendSuccess($stats);
        } catch (Exception $e) {
            Response::sendError('Error retrieving dashboard data: ' . $e->getMessage());
        }
    }
    
    public function getSalesReport($params, $user_data) {
        try {
            $start_date = isset($_GET['start_date']) ? $_GET['start_date'] : date('Y-m-01');
            $end_date = isset($_GET['end_date']) ? $_GET['end_date'] : date('Y-m-t');
            
            $report = $this->orderModel->getSalesReport($start_date, $end_date);
            
            Response::sendSuccess($report);
        } catch (Exception $e) {
            Response::sendError('Error retrieving sales report: ' . $e->getMessage());
        }
    }
    
    public function getSalesData($params, $user_data) {
        try {
            $period = isset($_GET['period']) ? $_GET['period'] : 'month';
            
            $salesData = $this->adminModel->getSalesData($period);
            
            Response::sendSuccess($salesData);
        } catch (Exception $e) {
            Response::sendError('Error retrieving sales data: ' . $e->getMessage());
        }
    }
    
    public function getUserGrowth($params, $user_data) {
        try {
            $userGrowth = $this->adminModel->getUserGrowth();
            
            Response::sendSuccess($userGrowth);
        } catch (Exception $e) {
            Response::sendError('Error retrieving user growth data: ' . $e->getMessage());
        }
    }
}