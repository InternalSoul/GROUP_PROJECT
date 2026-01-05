package com.mycompany.oscp.model;
import java.util.List;

public class Customer extends User {

    public Customer() {
        super("customer", "", "", "", "");
    }

    public Customer(String role, String username, String email, String password, String address) {
        super(role, username, email, password, address);
    }

    public void placeOrder(Order order) {
        order.setUser(this);
        order.createOrder();
        System.out.println("Order placed by customer: " + getUsername());
    }

    public void viewOrderHistory(List<Order> orders) {
        System.out.println("Viewing order history for: " + getUsername());
        for (Order order : orders) {
            System.out.println("Order ID: " + order.getId() + " - Status: " + order.getStatus() + " - Total: $"
                    + String.format("%.2f", order.calcTotal()));
        }
    }

    public void writeReview(Review review) {
        review.submitReview();
        System.out.println("Review written by: " + getUsername());
    }

    public void cancelOrder(Order order) {
        if ("Pending".equals(order.getStatus())) {
            order.cancelOrder();
            System.out.println("Order cancelled by customer: " + getUsername());
        }
    }
}
