package com.mycompany.oscp.model;

public class Product {
    private int id;
    private String name;
    private double price;
    private String image;
    private String sellerUsername;
    private String category;
    private String description;
    private int stockQuantity;
    private java.sql.Timestamp createdAt;
    private String productType;
    private String size;
    private String color;
    private String brand;
    private String material;
    private double rating;
    private boolean inStock;

    public Product() {
        this.id = 0;
        this.name = "";
        this.price = 0.0;
        this.image = "";
        this.sellerUsername = "";
        this.category = "";
        this.description = "";
        this.stockQuantity = 0;
        this.createdAt = null;
        this.productType = "";
        this.size = "";
        this.color = "";
        this.brand = "";
        this.material = "";
        this.rating = 0.0;
        this.inStock = true;
    }

    public Product(int id, String name, double price) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.image = "";
        this.sellerUsername = "";
        this.category = "";
        this.description = "";
        this.stockQuantity = 0;
        this.createdAt = null;
        this.productType = "";
        this.size = "";
        this.color = "";
        this.brand = "";
        this.material = "";
        this.rating = 0.0;
        this.inStock = true;
    }

    public Product(int id, String name, double price, String image) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.image = image;
        this.sellerUsername = "";
        this.category = "";
        this.description = "";
        this.stockQuantity = 0;
        this.createdAt = null;
        this.productType = "";
        this.size = "";
        this.color = "";
        this.brand = "";
        this.material = "";
        this.rating = 0.0;
        this.inStock = true;
    }

    public Product(int id, String name, double price, String image, String sellerUsername, String category) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.image = image;
        this.sellerUsername = sellerUsername;
        this.category = category;
        this.description = "";
        this.stockQuantity = 0;
        this.createdAt = null;
        this.productType = "";
        this.size = "";
        this.color = "";
        this.brand = "";
        this.material = "";
        this.rating = 0.0;
        this.inStock = true;
    }

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public void setSellerUsername(String sellerUsername) {
        this.sellerUsername = sellerUsername;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public void setCreatedAt(java.sql.Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public void setProductType(String productType) {
        this.productType = productType;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public void setMaterial(String material) {
        this.material = material;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public void setInStock(boolean inStock) {
        this.inStock = inStock;
    }

    // Getters
    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public double getPrice() {
        return price;
    }

    public String getImage() {
        return image;
    }

    public String getSellerUsername() {
        return sellerUsername;
    }

    public String getCategory() {
        return category;
    }

    public String getDescription() {
        return description;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public java.sql.Timestamp getCreatedAt() {
        return createdAt;
    }

    public String getProductType() {
        return productType;
    }

    public String getSize() {
        return size;
    }

    public String getColor() {
        return color;
    }

    public String getBrand() {
        return brand;
    }

    public String getMaterial() {
        return material;
    }

    public double getRating() {
        return rating;
    }

    public boolean isInStock() {
        return inStock;
    }
}
