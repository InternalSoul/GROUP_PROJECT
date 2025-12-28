package com.mycompany.oscp.model;

public abstract class Payment {
    private String paymentMethod;
    private double amount;
    private String status;

    public Payment() {
        this.paymentMethod = "";
        this.amount = 0;
        this.status = "Pending";
    }

    public Payment(String paymentMethod, double amount, String status) {
        this.paymentMethod = paymentMethod;
        this.amount = amount;
        this.status = status;
    }

    // Getters
    public String getPaymentMethod() {
        return paymentMethod;
    }

    public double getAmount() {
        return amount;
    }

    public String getStatus() {
        return status;
    }

    // Setters
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public abstract void processPayment();
}
