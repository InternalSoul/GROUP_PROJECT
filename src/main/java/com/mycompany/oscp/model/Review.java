package com.mycompany.oscp.model;

import java.sql.Timestamp;

public class Review {
    private int id;
    private int productId;
    private String userId;
    private String username;
    private double rating;
    private String comment;
    private Timestamp createdAt;

    public Review() {
        this.id = 0;
        this.productId = 0;
        this.userId = "";
        this.username = "";
        this.rating = 0.0;
        this.comment = "";
        this.createdAt = null;
    }

    public Review(double rating, String comment) {
        this();
        this.rating = rating;
        this.comment = comment;
    }

    // Getters
    public int getId() {
        return id;
    }

    public int getProductId() {
        return productId;
    }

    public String getUserId() {
        return userId;
    }

    public String getUsername() {
        return username;
    }

    public double getRating() {
        return rating;
    }

    public String getComment() {
        return comment;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public void submitReview() {
        // Placeholder for persistence layer
        System.out.println("Review submitted");
    }
}
