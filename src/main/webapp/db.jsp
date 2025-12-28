<%@ page import="java.sql.*, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Test - OCSP</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: #fafafa;
            color: #1a1a1a;
            min-height: 100vh;
        }
        .top-bar {
            background: #1a1a1a;
            color: #fff;
            text-align: center;
            padding: 10px;
            font-size: 12px;
            letter-spacing: 1px;
            text-transform: uppercase;
        }
        .navbar {
            background: #fff;
            padding: 20px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
        }
        .navbar .logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.8em;
            font-weight: 700;
            color: #1a1a1a;
            text-decoration: none;
            letter-spacing: 2px;
        }
        .navbar a {
            color: #1a1a1a;
            text-decoration: none;
            font-size: 13px;
            letter-spacing: 1px;
            text-transform: uppercase;
            transition: opacity 0.3s;
        }
        .navbar a:hover {
            opacity: 0.6;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 50px 30px;
        }
        .page-header {
            text-align: center;
            margin-bottom: 50px;
        }
        .page-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.5em;
            font-weight: 400;
            letter-spacing: 2px;
            margin-bottom: 10px;
        }
        .page-header p {
            color: #888;
            font-size: 14px;
            letter-spacing: 1px;
        }
        .card {
            background: #fff;
            border: 1px solid #eee;
            padding: 35px;
            margin-bottom: 25px;
        }
        .card h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.3em;
            font-weight: 400;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        .status {
            padding: 12px 20px;
            font-size: 13px;
            letter-spacing: 1px;
            margin-bottom: 15px;
            display: inline-block;
        }
        .status.success {
            background: #1a1a1a;
            color: #fff;
        }
        .status.error {
            background: #fff;
            color: #c00;
            border: 1px solid #c00;
        }
        .info {
            color: #666;
            font-size: 14px;
            line-height: 1.8;
        }
        .info code {
            background: #f5f5f5;
            padding: 3px 8px;
            font-family: 'Consolas', monospace;
            font-size: 13px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        table th,
        table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        table th {
            font-size: 11px;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: #888;
            font-weight: 500;
            background: #fafafa;
        }
        table tr:hover {
            background: #fafafa;
        }
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #888;
            font-size: 14px;
        }
        .btn {
            display: inline-block;
            padding: 14px 30px;
            background: #1a1a1a;
            color: #fff;
            text-decoration: none;
            font-size: 12px;
            letter-spacing: 2px;
            text-transform: uppercase;
            transition: background 0.3s;
            border: none;
            cursor: pointer;
        }
        .btn:hover {
            background: #333;
        }
        .action-bar {
            margin-top: 30px;
            text-align: center;
        }
        .footer {
            background: #1a1a1a;
            color: #fff;
            padding: 50px;
            text-align: center;
            margin-top: 50px;
        }
        .footer-logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.5em;
            letter-spacing: 3px;
            margin-bottom: 20px;
        }
        .footer p {
            font-size: 12px;
            color: #888;
            letter-spacing: 1px;
        }
    </style>
</head>
<body>
    <div class="top-bar">
        Database Administration — System Status
    </div>

    <nav class="navbar">
        <a href="index.jsp" class="logo">OCSP</a>
        <a href="index.jsp">Back to Home</a>
    </nav>

    <div class="container">
        <div class="page-header">
            <h1>Database Test</h1>
            <p>Check database connection and view data</p>
        </div>

        <%
            Connection conn = null;
            boolean connected = false;
            String errorMsg = "";
            
            try {
                conn = DatabaseConnection.getConnection();
                connected = (conn != null && !conn.isClosed());
            } catch (Exception e) {
                errorMsg = e.getMessage();
            }
        %>

        <div class="card">
            <h2>Connection Status</h2>
            <% if (connected) { %>
                <span class="status success">Connected Successfully</span>
                <p class="info">Database: <code>jdbc:derby://localhost:1527/Clothing_store</code></p>
            <% } else { %>
                <span class="status error">Connection Failed</span>
                <p class="info">Error: <%= errorMsg %></p>
            <% } %>
        </div>

        <% if (connected) { %>
            <div class="card">
                <h2>Users Table</h2>
                <%
                    try {
                        String sql = "SELECT * FROM USERS";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        boolean hasUsers = false;
                %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Role</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                hasUsers = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("USER_ID") %></td>
                            <td><%= rs.getString("USERNAME") %></td>
                            <td><%= rs.getString("EMAIL") %></td>
                            <td><%= rs.getString("ROLE") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% if (!hasUsers) { %>
                    <div class="empty-state">No users found in database.</div>
                <% }
                    rs.close();
                    ps.close();
                } catch (SQLException e) {
                %>
                    <div class="empty-state">Error: <%= e.getMessage() %></div>
                <% } %>
            </div>

            <div class="card">
                <h2>Products Table</h2>
                <%
                    try {
                        String sql = "SELECT * FROM PRODUCTS";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        boolean hasProducts = false;
                %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Price</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                hasProducts = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("PRODUCT_ID") %></td>
                            <td><%= rs.getString("NAME") %></td>
                            <td>RM <%= String.format("%.2f", rs.getDouble("PRICE")) %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% if (!hasProducts) { %>
                    <div class="empty-state">No products found in database.</div>
                <% }
                    rs.close();
                    ps.close();
                } catch (SQLException e) {
                %>
                    <div class="empty-state">Error: <%= e.getMessage() %></div>
                <% } %>
            </div>

            <div class="card">
                <h2>Orders Table</h2>
                <%
                    try {
                        String sql = "SELECT * FROM ORDERS";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        boolean hasOrders = false;
                %>
                <table>
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>User ID</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                hasOrders = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("ORDER_ID") %></td>
                            <td><%= rs.getInt("USER_ID") %></td>
                            <td>RM <%= String.format("%.2f", rs.getDouble("TOTAL_AMOUNT")) %></td>
                            <td><%= rs.getString("STATUS") %></td>
                            <td><%= rs.getTimestamp("ORDER_DATE") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% if (!hasOrders) { %>
                    <div class="empty-state">No orders found in database.</div>
                <% }
                    rs.close();
                    ps.close();
                } catch (SQLException e) {
                %>
                    <div class="empty-state">Error: <%= e.getMessage() %></div>
                <% } %>
            </div>

            <div class="card">
                <h2>Reviews Table</h2>
                <%
                    try {
                        String sql = "SELECT * FROM REVIEWS";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        boolean hasReviews = false;
                %>
                <table>
                    <thead>
                        <tr>
                            <th>Review ID</th>
                            <th>User ID</th>
                            <th>Product ID</th>
                            <th>Rating</th>
                            <th>Comment</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                hasReviews = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("REVIEW_ID") %></td>
                            <td><%= rs.getInt("USER_ID") %></td>
                            <td><%= rs.getInt("PRODUCT_ID") %></td>
                            <td><%= rs.getInt("RATING") %> ★</td>
                            <td><%= rs.getString("COMMENT") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% if (!hasReviews) { %>
                    <div class="empty-state">No reviews found in database.</div>
                <% }
                    rs.close();
                    ps.close();
                } catch (SQLException e) {
                %>
                    <div class="empty-state">Error: <%= e.getMessage() %></div>
                <% } %>
            </div>
        <% } %>

        <div class="action-bar">
            <a href="index.jsp" class="btn">Back to Home</a>
        </div>

        <%
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </div>

    <footer class="footer">
        <div class="footer-logo">OCSP</div>
        <p>© 2024 Online Shopping Clothing Platform. All Rights Reserved.</p>
    </footer>
</body>
</html>
