package model;

public class OrderDetails {
    private int quantity;
    private double price;
    private Product product;

    public OrderDetails() {
        this.quantity = 0;
        this.price = 0.0;
        this.product = null;
    }

    public OrderDetails(int quantity, double price, Product product) {
        this.quantity = quantity;
        this.price = price;
        this.product = product;
    }

    public Product getProduct() {
        return product;
    }

    public int getQuantity() {
        return quantity;
    }

    public double getPrice() {
        return price;
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
