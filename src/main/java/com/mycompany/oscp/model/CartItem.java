package com.mycompany.oscp.model;

public class CartItem {
    private Product product;
    private int quantity;

    public CartItem() {
        this.product = null;
        this.quantity = 0;
    }

    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public void incrementQuantity(int amount) {
        this.quantity += amount;
    }

    public double getSubtotal() {
        if (product != null) {
            return product.getPrice() * quantity;
        }
        return 0.0;
    }

    @Override
    public String toString() {
        return "CartItem{" +
                "product=" + (product != null ? product.getName() : "null") +
                ", quantity=" + quantity +
                ", subtotal=" + getSubtotal() +
                '}';
    }
}
