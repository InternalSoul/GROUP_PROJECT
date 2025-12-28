package com.mycompany.oscp.model;

import java.util.List;

public class Customer extends User {

    public Customer() {
        super();
        setRole("customer");
    }

    public Customer(int id, String username, String email, String password, String address) {
        super(id, username, email, password, "customer", address);
    }

    public void placeOrder(Order order) {
        order.createOrder();
        System.out.println("Order placed by customer: " + getUsername());
    }

    public void viewOrderHistory(List<Order> orders) {
        System.out.println("Viewing order history for: " + getUsername());
        for (Order order : orders) {
            System.out.println("Order ID: " + order.getId() + " - Status: " + order.getStatus());
        }
    }

    public void writeReview(Review review) {
        review.submitReview();
        System.out.println("Review written by: " + getUsername());
    }
}
