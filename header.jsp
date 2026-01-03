<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, model.*" %>
<%
    User user = (User) session.getAttribute("user");
    List<Product> cart = (List<Product>) session.getAttribute("cart");
    int cartCount = (cart != null) ? cart.size() : 0;
%>
<div class="top-bar">FREE SHIPPING ON ORDERS OVER $200</div>
<nav class="navbar">
    <a href="index.jsp" class="logo">CLOTHING STORE</a>
    <div class="nav-links">
        <a href="products">Shop</a>
        <a href="cart">Cart<span class="cart-count"><%= cartCount %></span></a>
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
