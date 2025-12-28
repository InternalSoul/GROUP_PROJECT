<%@ page import="java.util.*, model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"customer".equals(user.getRole())) {
        response.sendRedirect("login");
        return;
    }

    List<Product> products = (List<Product>) request.getAttribute("products");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Products</title>
</head>
<body>

<h2>Available Products</h2>

<div style="margin-bottom: 20px;">
    <form action="products" method="get">
        <input type="text" name="search" placeholder="Search by name..." value="${param.search}">
        <button type="submit">Search</button>
        <% if (request.getParameter("search") != null) { %>
            <a href="products"><button type="button">Clear</button></a>
        <% } %>
    </form>
</div>
<% if (products == null || products.isEmpty()) { %>
    <p>No products found.</p>
<% } else { %>

<table border="1">
<tr>
    <th>Name</th><th>Price</th><th>Action</th>
</tr>

<% for (Product p : products) { %>
<tr>
    <td><%= p.getName() %></td>
    <td>$<%= p.getPrice() %></td>
    <td>
        <form action="<%=request.getContextPath()%>/cart" method="post">
            <input type="hidden" name="id" value="<%= p.getId() %>">
            <input type="hidden" name="name" value="<%= p.getName() %>">
            <input type="hidden" name="price" value="<%= p.getPrice() %>">
            <button type="submit">Add to Cart</button>
        </form>
    </td>
</tr>
<% } %>

</table>
<% } %>

<br>
<a href="cart.jsp">View Cart</a>
<form action="logout" method="get" style="display:inline;">
    <button type="submit">Logout</button>
</form>

</body>
</html>