<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.oscp.model.*"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Tracking - DormDealz</title>
    <link rel="stylesheet" href="css/uitm-theme.css">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-secondary);
            min-height: 100vh;
            color: var(--text-primary);
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: var(--bg-primary);
            padding: 32px 24px;
            border-radius: 12px;
            box-shadow: var(--shadow-md);
        }
        h1 {
            color: var(--primary-purple);
            border-bottom: 2px solid var(--primary-purple);
            padding-bottom: 10px;
        }
        .order-card {
            border: 1px solid var(--border-light);
            border-radius: 10px;
            padding: 24px;
            margin-bottom: 24px;
            background: var(--bg-secondary);
        }
        .order-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-medium);
        }
        .order-id {
            font-weight: bold;
            font-size: 1.2em;
            color: var(--primary-purple);
        }
        .status {
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.9em;
        }
        .status.pending { background: #ffe9a7; color: #a67c00; }
        .status.processing { background: #e0e7ff; color: #5b21b6; }
        .status.shipped { background: #e9d5ff; color: #7c3aed; }
        .status.delivered { background: #d1fae5; color: #065f46; }
        .status.cancelled { background: #fee2e2; color: #b91c1c; }
        .tracking-info {
            background: var(--bg-primary);
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            box-shadow: var(--shadow-sm);
        }
        .tracking-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid var(--border-light);
        }
        .tracking-item:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: bold;
            color: var(--text-secondary);
        }
        .value {
            color: var(--text-primary);
        }
        .no-orders {
            text-align: center;
            padding: 40px;
            color: var(--text-secondary);
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 28px;
            background: var(--primary-purple);
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            letter-spacing: 1px;
            transition: background 0.3s;
        }
        .back-link:hover {
            background: var(--primary-dark);
        }
        .error {
            background: #fee2e2;
            color: #b91c1c;
            padding: 15px;
            border-radius: 8px;
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
