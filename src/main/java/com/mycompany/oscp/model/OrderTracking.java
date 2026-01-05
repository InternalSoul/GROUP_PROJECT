package com.mycompany.oscp.model;

import java.sql.*;
import java.util.Date;

public class OrderTracking {
    private int trackingId;
    private int orderId;
    private String currentLocation;
    private Date estimatedDelivery;
    private Date lastUpdated;

    // Constructors
    public OrderTracking() {
    }

    public OrderTracking(int orderId, String currentLocation, Date estimatedDelivery) {
        this.orderId = orderId;
        this.currentLocation = currentLocation;
        this.estimatedDelivery = estimatedDelivery;
        this.lastUpdated = new Date();
    }

    // Getters and Setters
    public int getTrackingId() {
        return trackingId;
    }

    public void setTrackingId(int trackingId) {
        this.trackingId = trackingId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getCurrentLocation() {
        return currentLocation;
    }

    public void setCurrentLocation(String currentLocation) {
        this.currentLocation = currentLocation;
    }

    public Date getEstimatedDelivery() {
        return estimatedDelivery;
    }

    public void setEstimatedDelivery(Date estimatedDelivery) {
        this.estimatedDelivery = estimatedDelivery;
    }

    public Date getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Date lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    /**
     * Updates tracking information for an order
     */
    public boolean updateTracking() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE order_tracking SET current_location = ?, estimated_delivery = ?, last_updated = ? " +
                    "WHERE order_id = ?";

            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, currentLocation);
            pstmt.setTimestamp(2, new Timestamp(estimatedDelivery.getTime()));
            pstmt.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            pstmt.setInt(4, orderId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Gets tracking information for a specific order
     */
    public static OrderTracking getTrackingByOrderId(int orderId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM order_tracking WHERE order_id = ?";

            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, orderId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                OrderTracking tracking = new OrderTracking();
                tracking.setTrackingId(rs.getInt("tracking_id"));
                tracking.setOrderId(rs.getInt("order_id"));
                tracking.setCurrentLocation(rs.getString("current_location"));
                tracking.setEstimatedDelivery(rs.getTimestamp("estimated_delivery"));
                tracking.setLastUpdated(rs.getTimestamp("last_updated"));
                return tracking;
            }
            return null;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }
}
