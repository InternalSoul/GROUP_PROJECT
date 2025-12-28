package com.mycompany.oscp.model;

public class OrderDetails {
    private int id;
    private int quantity;
    private double price;
    private Product product;

    public OrderDetails() {
        this.id = 0;
        this.quantity = 0;
        this.price = 0.0;
        this.product = null;
    }

    public OrderDetails(int quantity, double price, Product product) {
        this.id = 0;
        this.quantity = quantity;
        this.price = price;
        this.product = product;
    }

    // Getters
    public int getId() {
        return id;
    }

    public int getQuantity() {
        return quantity;
    }

    public double getPrice() {
        return price;
    }

    public Product getProduct() {
        return product;
    }

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public double calcSubTotal() {
        return quantity * price;
    }
}
