<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.*, java.sql.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }

    // Determine which order to track: prefer explicit orderId param, fall back to
    // the last order id stored in session.
    String orderIdParam = request.getParameter("orderId");
    Integer dbOrderId = null;
    if (orderIdParam != null && !orderIdParam.isEmpty()) {
        try { dbOrderId = Integer.parseInt(orderIdParam); } catch (NumberFormatException ignored) {}
    }
    if (dbOrderId == null) {
        dbOrderId = (Integer) session.getAttribute("orderDbId");
    }

    String dbStatus = null;
    if (dbOrderId != null) {
        try (Connection conn = model.DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status FROM orders WHERE id = ? AND user_username = ?")) {
            ps.setInt(1, dbOrderId);
            ps.setString(2, user.getUsername());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    dbStatus = rs.getString("status");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Map DB status (Pending, Completed, Cancelled, etc.) into a timeline
    // status used by the UI (Processing, Shipped, Delivered).
    String timelineStatus;
    if (dbStatus == null) {
        timelineStatus = "Processing";
    } else if ("Completed".equalsIgnoreCase(dbStatus)) {
        timelineStatus = "Delivered";
    } else if ("Cancelled".equalsIgnoreCase(dbStatus)) {
        timelineStatus = "Processing"; // order cancelled, but we keep timeline minimal
    } else {
        timelineStatus = "Processing";
    }

    String orderId = (dbOrderId != null) ? ("ORD" + dbOrderId) : ("ORD" + System.currentTimeMillis());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Track Order - Clothing Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; color: #1a1a1a; }
        .top-bar { background: #1a1a1a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .cart-count { background: #1a1a1a; color: #fff; padding: 2px 8px; font-size: 0.75em; margin-left: 5px; }
        .user-name { color: #888; font-size: 0.85em; }
        .container { max-width: 900px; margin: 0 auto; padding: 60px 30px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.5em; font-weight: 400; letter-spacing: 2px; margin-bottom: 40px; text-align: center; }
        .tracking-box { background: #fff; border: 1px solid #eee; padding: 50px; }
        .order-info { background: #f5f5f5; padding: 25px; margin-bottom: 40px; text-align: center; }
        .order-info span { font-size: 0.8em; color: #888; text-transform: uppercase; letter-spacing: 1px; display: block; margin-bottom: 8px; }
        .order-info strong { font-size: 1.3em; letter-spacing: 2px; }
        .status-timeline { margin: 50px 0; }
        .status-item { display: flex; align-items: center; margin-bottom: 30px; position: relative; }
        .status-item:last-child { margin-bottom: 0; }
        .status-icon { width: 50px; height: 50px; border-radius: 50%; background: #1a1a1a; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.3em; margin-right: 25px; flex-shrink: 0; }
        .status-item.inactive .status-icon { background: #eee; color: #bbb; }
        .status-details h3 { font-size: 1em; font-weight: 600; letter-spacing: 1px; margin-bottom: 5px; }
        .status-details p { color: #888; font-size: 0.9em; }
        .action-buttons { display: flex; gap: 15px; margin-top: 40px; justify-content: center; }
        .btn { padding: 16px 35px; background: #1a1a1a; color: #fff; text-decoration: none; font-size: 0.85em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; transition: background 0.3s; }
        .btn:hover { background: #333; }
        .btn-outline { background: transparent; color: #1a1a1a; border: 1px solid #1a1a1a; }
        .btn-outline:hover { background: #1a1a1a; color: #fff; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 60px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    <div class="container">
        <h1>Order Tracking</h1>
        <div class="tracking-box">
            <div class="order-info">
                <span>Order Number</span>
                <strong><%= orderId %></strong>
            </div>
            <div class="status-timeline">
                <div class="status-item">
                    <div class="status-icon">✓</div>
                    <div class="status-details">
                        <h3>Order Placed</h3>
                        <p>Your order has been received</p>
                    </div>
                </div>
                <div class="status-item <%= "Processing".equals(timelineStatus) || "Shipped".equals(timelineStatus) || "Delivered".equals(timelineStatus) ? "" : "inactive" %>">
                    <div class="status-icon">📦</div>
                    <div class="status-details">
                        <h3>Processing</h3>
                        <p>We're preparing your items</p>
                    </div>
                </div>
                <div class="status-item <%= "Shipped".equals(timelineStatus) || "Delivered".equals(timelineStatus) ? "" : "inactive" %>">
                    <div class="status-icon">🚚</div>
                    <div class="status-details">
                        <h3>Shipped</h3>
                        <p>Your order is on the way</p>
                    </div>
                </div>
                <div class="status-item <%= "Delivered".equals(timelineStatus) ? "" : "inactive" %>">
                    <div class="status-icon">✓</div>
                    <div class="status-details">
                        <h3>Delivered</h3>
                        <p>Order has been delivered</p>
                    </div>
                </div>
            </div>
            <div class="action-buttons">
                <a href="products" class="btn">Continue Shopping</a>
                <a href="review.jsp" class="btn btn-outline">Write Review</a>
            </div>
        </div>
    </div>
    <footer class="footer"><div class="footer-logo">CLOTHING STORE</div><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
