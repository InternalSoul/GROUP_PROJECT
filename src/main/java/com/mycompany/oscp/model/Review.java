package com.mycompany.oscp.model;

public class Review {
    private int id;
    private int rating;
    private String comment;
    private int productId;
    private int userId;

    public Review() {
        this.id = 0;
        this.rating = 0;
        this.comment = "";
        this.productId = 0;
        this.userId = 0;
    }

    public Review(int rating, String comment) {
        this.id = 0;
        this.rating = rating;
        this.comment = comment;
        this.productId = 0;
        this.userId = 0;
    }

    public Review(int id, int rating, String comment, int productId, int userId) {
        this.id = id;
        this.rating = rating;
        this.comment = comment;
        this.productId = productId;
        this.userId = userId;
    }

    // Getters
    public int getId() {
        return id;
    }

    public int getRating() {
        return rating;
    }

    public String getComment() {
        return comment;
    }

    public int getProductId() {
        return productId;
    }

    public int getUserId() {
        return userId;
    }

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public void submitReview() {
        System.out.println("Review submitted with rating: " + rating);
    }
}
