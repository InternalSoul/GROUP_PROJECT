package com.mycompany.oscp.model;

public class User {
    protected String role;
    private String username;
    private String email;
    private String password;
    private String address;
    private String phone;

    public User() {
        this.role = "";
        this.username = "";
        this.email = "";
        this.password = "";
        this.address = "";
        this.phone = "";
    }

    public User(String role, String username, String email, String password, String address) {
        this.role = role;
        this.username = username;
        this.email = email;
        this.password = password;
        this.address = address;
        this.phone = "";
    }

    // Getters
    public String getRole() {
        return role;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public String getAddress() {
        return address;
    }

    public String getPassword() {
        return password;
    }

    public String getPhone() {
        return phone;
    }

    // Setters
    public void setRole(String role) {
        this.role = role;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    // Actions
    public void register() {
        System.out.println(username + " registered successfully.");
    }

    public void login() {
        System.out.println(username + " logged in successfully.");
    }
}
