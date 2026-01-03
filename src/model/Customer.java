package model;

import java.util.List;

public class Customer extends User {

    public Customer() {
        super("customer", "", "", "", ""); // default values
    }

    public Customer(String role, String username, String email, String password, String address) {
        super(role, username, email, password, address);
    }

    public void placeOrder(Order order) {
        System.out.println("Order placed");
    }

    public void viewOrderHistory(List<Order> orders) {
        System.out.println("Viewing order history");
    }

    public void writeReview(Review review) {
        review.submitReview();
    }
}
