<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.mycompany.oscp.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    int cartCount = 0;

    if (user != null) {
        // Count items from carts/cart_items for this user so the cart
        // persists correctly across logout/login.
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COALESCE(SUM(ci.quantity),0) AS cnt " +
                 "FROM carts c " +
                 "LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id " +
                 "WHERE c.customer_username = ?")) {
            ps.setString(1, user.getUsername());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    cartCount = rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // If DB lookup fails for any reason, fall back to session cart.
            cartCount = (cart != null) ? cart.size() : 0;
        }
    } else {
        cartCount = (cart != null) ? cart.size() : 0;
    }
%>
<div class="top-bar">FREE SHIPPING ON ORDERS OVER $200</div>
<nav class="navbar">
    <a href="index.jsp" class="logo">CLOTHING STORE</a>
    <div class="nav-links">
        <a href="products">Shop</a>
        <a href="cart">Cart <span class="cart-count"><%= cartCount %></span></a>
        <a href="orderHistory">Order History</a>
        <% if (user != null && ("seller".equals(user.getRole()) || "admin".equals(user.getRole()))) { %>
            <a href="sellerShop.jsp">My Shop</a>
        <% } %>
        <% if (user != null) { %>
            <span class="user-name">Hi, <%= user.getUsername() %></span>
            <a href="logout">Logout</a>
        <% } else { %>
            <a href="login">Login</a>
        <% } %>
    </div>
</nav>
