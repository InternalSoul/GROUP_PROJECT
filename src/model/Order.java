package model;

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

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setOrderDetails(List<OrderDetails> orderDetails) {
        this.orderDetails = orderDetails;
    }

    public void setUser(User user) {
        this.user = user;
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

    public void createOrder() {
        System.out.println("Order created with ID: " + id);
    }

    public void cancelOrder() {
        this.status = "Cancelled";
        System.out.println("Order " + id + " cancelled");
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
