package com.mycompany.oscp.model;

import java.sql.*;
import java.util.Date;
import java.util.List;

public class Order {
    private int id;
    private int orderId;
    private int customerId;
    private Date date;
    private Date orderDate;
    private double totalAmount;
    private String status;
    private String paymentMethod;
    private String address;
    private List<OrderDetails> orderDetails;
    private Payment payment;
    private User user;
    private OrderTracking tracking;

    public Order() {
        this.id = 0;
        this.date = new Date();
        this.status = "Pending";
        this.orderDetails = null;
        this.payment = null;
        this.user = null;
    }

    public Order(int id, Date date, String status, List<OrderDetails> orderDetails, Payment payment, User user) {
        this.id = id;
        this.date = date;
        this.status = status;
        this.orderDetails = orderDetails;
        this.payment = payment;
        this.user = user;
    }

    // Getters
    public int getId() {
        return id;
    }

    public int getOrderId() {
        return orderId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public Date getDate() {
        return date;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public String getAddress() {
        return address;
    }

    public List<OrderDetails> getOrderDetails() {
        return orderDetails;
    }

    public Payment getPayment() {
        return payment;
    }

    public User getUser() {
        return user;
    }

    public OrderTracking getTracking() {
        return tracking;
    }

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public void setOrderDetails(List<OrderDetails> orderDetails) {
        this.orderDetails = orderDetails;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setTracking(OrderTracking tracking) {
        this.tracking = tracking;
    }

    public double calcTotal() {
        if (orderDetails == null)
            return 0;
        double total = 0;
        for (OrderDetails od : orderDetails) {
            total += od.calcSubTotal();
        }
        return total;
    }

    /**
     * Creates a new order in the database
     */
    public boolean createOrder() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "INSERT INTO orders (customer_id, order_date, total_amount, status, payment_method, address) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";
            
            PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, customerId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.setDouble(3, totalAmount);
            pstmt.setString(4, status != null ? status : "Pending");
            pstmt.setString(5, paymentMethod);
            pstmt.setString(6, address);
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    this.orderId = rs.getInt(1);
                    this.id = this.orderId;
                    
                    // Create initial tracking entry
                    createInitialTracking();
                    System.out.println("Order created with ID: " + id);
                    return true;
                }
            }
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Creates initial tracking entry for a new order
     */
    private void createInitialTracking() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "INSERT INTO order_tracking (order_id, current_location, estimated_delivery, last_updated) " +
                        "VALUES (?, ?, ?, ?)";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, orderId);
            pstmt.setString(2, "Order Placed - Processing");
            
            // Estimated delivery: 7 days from now
            Timestamp estimatedDelivery = new Timestamp(System.currentTimeMillis() + (7L * 24 * 60 * 60 * 1000));
            pstmt.setTimestamp(3, estimatedDelivery);
            pstmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void cancelOrder() {
        this.status = "Cancelled";
        System.out.println("Order " + id + " cancelled");
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
