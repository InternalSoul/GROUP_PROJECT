<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    List<Order> customerOrders = (List<Order>) request.getAttribute("customerOrders");
    List<Order> sellerOrders = (List<Order>) request.getAttribute("sellerOrders");
    if (customerOrders == null) customerOrders = new ArrayList<>();
    if (sellerOrders == null) sellerOrders = new ArrayList<>();
    
    String errorMsg = (String) session.getAttribute("error");
    if (errorMsg != null) {
        session.removeAttribute("error");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order History - DormDealz</title>
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
        .container { max-width: 1100px; margin: 0 auto; padding: 50px 30px 70px; }
        h1 { font-family: 'Playfair Display', serif; font-size: 2.2em; font-weight: 400; letter-spacing: 2px; margin-bottom: 30px; }
        .section-title { font-size: 1.1em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; margin: 30px 0 15px; }
        .orders-table { width: 100%; border-collapse: collapse; background: #fff; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
        .orders-table th { background: #f5f5f5; padding: 14px; text-align: left; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; border-bottom: 1px solid #eee; }
        .orders-table td { padding: 14px; border-bottom: 1px solid #eee; font-size: 0.9em; vertical-align: top; }
        .orders-table tbody tr { opacity: 0; animation: fadeInRow 0.5s ease-out forwards; transition: background 0.2s ease; }
        .orders-table tbody tr:nth-child(1) { animation-delay: 0.1s; }
        .orders-table tbody tr:nth-child(2) { animation-delay: 0.2s; }
        .orders-table tbody tr:nth-child(3) { animation-delay: 0.3s; }
        .orders-table tbody tr:nth-child(4) { animation-delay: 0.4s; }
        .orders-table tbody tr:nth-child(5) { animation-delay: 0.5s; }
        @keyframes fadeInRow { from { opacity: 0; transform: translateX(-20px); } to { opacity: 1; transform: translateX(0); } }
        .orders-table tbody tr:hover { background: #fafafa; }
        .orders-table tr:last-child td { border-bottom: none; }
        .order-thumb { width: 60px; height: 60px; background: #f5f5f5; display: flex; justify-content: center; align-items: center; overflow: hidden; font-size: 1.4em; color: #ddd; border-radius: 4px; }
        .order-thumb img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .order-items { font-size: 0.85em; color: #555; line-height: 1.5; }
        .order-items div { margin-bottom: 4px; }
        .status-badge { display: inline-block; padding: 4px 10px; border-radius: 999px; font-size: 0.75em; letter-spacing: 0.5px; text-transform: uppercase; }
        .status-pending { background: #fff7ed; color: #c05621; border: 1px solid #fed7aa; }
        .status-completed { background: #ecfdf3; color: #166534; border: 1px solid #bbf7d0; }
        .status-cancelled { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .empty { padding: 30px; text-align: center; background: #fff; border: 1px solid #eee; color: #888; font-size: 0.95em; }
        .track-btn { display: inline-block; padding: 8px 14px; font-size: 0.8em; letter-spacing: 1px; text-transform: uppercase; border: 1px solid #1a1a1a; background: #fff; color: #1a1a1a; text-decoration: none; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .track-btn:hover { background: #1a1a1a; color: #fff; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .review-btn { display: inline-block; padding: 8px 14px; font-size: 0.8em; letter-spacing: 1px; text-transform: uppercase; border: 1px solid #166534; background: #fff; color: #166534; text-decoration: none; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); margin-top: 6px; }
        .review-btn:hover { background: #166534; color: #fff; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(22, 101, 52, 0.2); }
        .action-buttons { display: flex; flex-direction: column; gap: 6px; }
        .footer { background: #1a1a1a; color: #fff; padding: 40px; text-align: center; margin-top: 60px; }
        .footer-logo { font-family: 'Playfair Display', serif; font-size: 1.5em; letter-spacing: 3px; margin-bottom: 15px; }
        .footer p { color: #666; font-size: 0.8em; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    <div class="container">
        <h1>Order History</h1>
        
        <% if (errorMsg != null) { %>
        <div style="background:#fef2f2; border:1px solid #fecaca; color:#b91c1c; padding:14px; margin-bottom:20px; border-radius:8px;">
            <%= errorMsg %>
        </div>
        <% } %>

        <div class="section-title">Your Purchases</div>
        <% if (customerOrders.isEmpty()) { %>
            <div class="empty">You have no past orders yet.</div>
        <% } else { %>
            <table class="orders-table">
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Items</th>
                        <th>Total</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Order o : customerOrders) { %>
                        <tr>
                            <td>
                                <div style="display:flex; gap:6px; flex-wrap:wrap;">
                                    <%
                                       boolean anyImage = false;
                                       if (o.getOrderDetails() != null) {
                                           for (OrderDetails od : o.getOrderDetails()) {
                                               Product p = od.getProduct();
                                               if (p != null && p.getImage() != null && !p.getImage().isEmpty()) {
                                    %>
                                                <a href="product?id=<%= p.getId() %>" style="display:block;">
                                                    <div class="order-thumb">
                                                        <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                                                    </div>
                                                </a>
                                    <%
                                                   anyImage = true;
                                               }
                                           }
                                       }
                                       if (!anyImage) {
                                    %>
                                           <div class="order-thumb">◇</div>
                                    <%
                                       }
                                    %>
                                </div>
                            </td>
                            <td><%= o.getDate() %></td>
                            <td>
                                <% String st = o.getStatus(); %>
                                <span class="status-badge <%= "Completed".equalsIgnoreCase(st) ? "status-completed" : ("Cancelled".equalsIgnoreCase(st) ? "status-cancelled" : "status-pending") %>"><%= st %></span>
                            </td>
                            <td>
                                <div class="order-items">
                                    <% if (o.getOrderDetails() != null) {
                                           for (OrderDetails od : o.getOrderDetails()) {
                                               Product p = od.getProduct(); %>
                                               <div><%= od.getQuantity() %> x <%= p != null ? p.getName() : "Item" %></div>
                                    <%   }
                                       } %>
                                </div>
                            </td>
                            <td>$<%= String.format("%.2f", o.calcTotal()) %></td>
                            <td>
                                <div class="action-buttons">
                                    <a href="tracking?orderId=<%= o.getId() %>" class="track-btn">Track Order</a>
                                    <% if ("Delivered".equalsIgnoreCase(o.getStatus()) && o.getOrderDetails() != null) {
                                           for (OrderDetails od : o.getOrderDetails()) {
                                               Product p = od.getProduct();
                                               if (p != null) { %>
                                                   <a href="product?id=<%= p.getId() %>#write-review" class="review-btn">Review <%= p.getName() %></a>
                                    <%         }
                                           }
                                       } %>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>

        <% if ("seller".equals(user.getRole()) || "admin".equals(user.getRole())) { %>
            <div class="section-title" style="margin-top:40px;">Your Sales</div>
            <% if (sellerOrders.isEmpty()) { %>
                <div class="empty">You have no sales yet.</div>
            <% } else { %>
                <table class="orders-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Date</th>
                            <th>Buyer</th>
                            <th>Items Sold</th>
                            <th>Total from You</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Order o : sellerOrders) {
                               double sellerTotal = 0;
                               if (o.getOrderDetails() != null) {
                                   for (OrderDetails od : o.getOrderDetails()) {
                                       sellerTotal += od.calcSubTotal();
                                   }
                               }
                        %>
                            <tr>
                                <td>
                                    <div style="display:flex; gap:6px; flex-wrap:wrap;">
                                        <%
                                           boolean anyImage = false;
                                           if (o.getOrderDetails() != null) {
                                               for (OrderDetails od : o.getOrderDetails()) {
                                                   Product p = od.getProduct();
                                                   if (p != null && p.getImage() != null && !p.getImage().isEmpty()) {
                                        %>
                                                    <a href="product?id=<%= p.getId() %>" style="display:block;">
                                                        <div class="order-thumb">
                                                            <img src="<%= p.getImage() %>" alt="<%= p.getName() %>">
                                                        </div>
                                                    </a>
                                        <%
                                                       anyImage = true;
                                                   }
                                               }
                                           }
                                           if (!anyImage) {
                                        %>
                                               <div class="order-thumb">◇</div>
                                        <%
                                           }
                                        %>
                                    </div>
                                </td>
                                <td><%= o.getDate() %></td>
                                <td><%= o.getUser() != null ? o.getUser().getUsername() : "Buyer" %></td>
                                <td>
                                    <div class="order-items">
                                        <% if (o.getOrderDetails() != null) {
                                               for (OrderDetails od : o.getOrderDetails()) {
                                                   Product p = od.getProduct(); %>
                                                   <div><%= od.getQuantity() %> x <%= p != null ? p.getName() : "Item" %></div>
                                        <%     }
                                           } %>
                                    </div>
                                </td>
                                <td>$<%= String.format("%.2f", sellerTotal) %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        <% } %>
    </div>
    <footer class="footer"><div class="footer-logo">DORMDEALZ</div><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
