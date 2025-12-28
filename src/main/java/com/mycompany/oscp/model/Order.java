package com.mycompany.oscp.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Order {
    private int id;
    private Date date;
    private String status;
    private List<OrderDetails> orderDetails;
    private Payment payment;
    private User user;

    public Order() {
        this.id = 0;
        this.date = new Date();
        this.status = "Pending";
        this.orderDetails = new ArrayList<>();
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

    public Date getDate() {
        return date;
    }

    public String getStatus() {
        return status;
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

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setOrderDetails(List<OrderDetails> orderDetails) {
        this.orderDetails = orderDetails;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public double calcTotal() {
        double total = 0;
        if (orderDetails != null) {
            for (OrderDetails od : orderDetails) {
                total += od.calcSubTotal();
            }
        }
        return total;
    }

    public void addOrderDetail(OrderDetails detail) {
        if (orderDetails == null) {
            orderDetails = new ArrayList<>();
        }
        orderDetails.add(detail);
    }

    public void createOrder() {
        System.out.println("Order created with ID: " + id);
    }

    public void cancelOrder() {
        this.status = "Cancelled";
        System.out.println("Order " + id + " cancelled");
    }
}
