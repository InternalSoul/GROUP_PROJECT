<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.oscp.model.*"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Tracking - DormDealz</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .top-bar { background: #1a1a1a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        .order-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            background: #fafafa;
        }
        .order-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #ddd;
        }
        .order-id {
            font-weight: bold;
            font-size: 1.2em;
            color: #007bff;
        }
        .status {
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.9em;
        }
        .status.pending { background: #ffc107; color: #000; }
        .status.processing { background: #17a2b8; color: #fff; }
        .status.shipped { background: #28a745; color: #fff; }
        .status.delivered { background: #6c757d; color: #fff; }
        .status.cancelled { background: #dc3545; color: #fff; }
        .tracking-info {
            background: white;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
        }
        .tracking-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .tracking-item:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: bold;
            color: #666;
        }
        .value {
            color: #333;
        }
        .no-orders {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .back-link:hover {
            background: #0056b3;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📦 Order Tracking</h1>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <%
            List<Order> orders = (List<Order>) request.getAttribute("orders");
            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            
            if (orders != null && !orders.isEmpty()) {
                for (Order order : orders) {
                    OrderTracking tracking = order.getTracking();
                    String statusClass = order.getStatus().toLowerCase().replace(" ", "-");
        %>
                    <div class="order-card">
                        <div class="order-header">
                            <div class="order-id">Order #<%= order.getOrderId() %></div>
                            <div class="status <%= statusClass %>"><%= order.getStatus() %></div>
                        </div>
                        
                        <div class="tracking-item">
                            <span class="label">Order Date:</span>
                            <span class="value"><%= dateFormat.format(order.getOrderDate()) %></span>
                        </div>
                        
                        <div class="tracking-item">
                            <span class="label">Total Amount:</span>
                            <span class="value">RM <%= String.format("%.2f", order.getTotalAmount()) %></span>
                        </div>
                        
                        <div class="tracking-item">
                            <span class="label">Payment Method:</span>
                            <span class="value"><%= order.getPaymentMethod() %></span>
                        </div>
                        
                        <div class="tracking-item">
                            <span class="label">Delivery Address:</span>
                            <span class="value"><%= order.getAddress() %></span>
                        </div>
                        
                        <% if (tracking != null) { %>
                            <div class="tracking-info">
                                <h3 style="margin-top: 0; color: #007bff;">🚚 Tracking Information</h3>
                                
                                <div class="tracking-item">
                                    <span class="label">Current Location:</span>
                                    <span class="value"><%= tracking.getCurrentLocation() != null ? tracking.getCurrentLocation() : "N/A" %></span>
                                </div>
                                
                                <div class="tracking-item">
                                    <span class="label">Estimated Delivery:</span>
                                    <span class="value">
                                        <%= tracking.getEstimatedDelivery() != null ? dateFormat.format(tracking.getEstimatedDelivery()) : "N/A" %>
                                    </span>
                                </div>
                                
                                <div class="tracking-item">
                                    <span class="label">Last Updated:</span>
                                    <span class="value">
                                        <%= tracking.getLastUpdated() != null ? dateFormat.format(tracking.getLastUpdated()) : "N/A" %>
                                    </span>
                                </div>
                            </div>
                        <% } else { %>
                            <div class="tracking-info">
                                <p style="color: #666; margin: 0;">Tracking information not available yet.</p>
                            </div>
                        <% } %>
                    </div>
        <%
                }
            } else {
        %>
                <div class="no-orders">
                    <h2>No orders found</h2>
                    <p>You haven't placed any orders yet.</p>
                    <a href="products" class="back-link">Browse Products</a>
                </div>
        <%
            }
        %>
        
        <a href="orderHistory" class="back-link">Back to Home</a>
    </div>
</body>
</html>
