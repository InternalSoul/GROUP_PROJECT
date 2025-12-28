package com.mycompany.oscp.model;

public class User {
    private int id;
    private String username;
    private String email;
    private String password;
    private String role;
    private String address;

    public User() {
        this.id = 0;
        this.username = "";
        this.email = "";
        this.password = "";
        this.role = "";
        this.address = "";
    }

    public User(int id, String username, String email, String password, String role, String address) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.role = role;
        this.address = address;
    }

    // Getters
    public int getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getRole() {
        return role;
    }

    public String getAddress() {
        return address;
    }

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setAddress(String address) {
        this.address = address;
    }
}
