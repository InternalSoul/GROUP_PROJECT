package com.mycompany.oscp.model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    // Derby database connection settings
    // Using the same database shown in your screenshot:
    // jdbc:derby://localhost:1527/Clothing_store
    private static final String URL = "jdbc:derby://localhost:1527/Clothing_store";
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
     * 
     * @return Connection to Clothing_store database
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    /**
     * Test the database connection
     * 
     * @return true if connection successful, false otherwise
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            return false;
        }
    }
}
