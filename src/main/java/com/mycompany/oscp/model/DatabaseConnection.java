package com.mycompany.oscp.model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    // Derby database connection settings
    private static final String URL = "jdbc:derby://localhost:1527/Clothing_store2;create=true";
    private static final String USER = "root";
    private static final String PASSWORD = "root";

    static {
        try {
            // Load Derby client driver
            Class.forName("org.apache.derby.jdbc.ClientDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("Derby JDBC Driver not found!");
            e.printStackTrace();
        }
    }

    /**
     * Returns a Connection object to the Derby database
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    /**
     * Test the database connection
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("Database connection successful!");
            return true;
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
