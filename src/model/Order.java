package model;

import java.util.Date;
import java.util.List;

public class Order {
    private Date date;
    private String status;
    private List<OrderDetails> orderDetails;
    private Payment payment;

    public Order() {
        this.date = new Date();
        this.status = "Pending";
        this.orderDetails = null;
        this.payment = null;
    }

    public Order(Date date, String status, List<OrderDetails> orderDetails, Payment payment) {
        this.date = date;
        this.status = status;
        this.orderDetails = orderDetails;
        this.payment = payment;
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

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setOrderDetails(List<OrderDetails> orderDetails) {
        this.orderDetails = orderDetails;
    }

    public double calcTotal() {
        double total = 0;
        for (OrderDetails od : orderDetails) {
            total += od.calcSubTotal();
        }
        return total;
    }

    public void createOrder() {
        System.out.println("Order created");
    }

    public void cancelOrder() {
        System.out.println("Order cancelled");
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
