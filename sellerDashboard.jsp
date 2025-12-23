<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"seller".equals(user.getRole())) {
        response.sendRedirect("login");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Seller Dashboard</title>
</head>
<body>

<h2>Welcome, Seller</h2>
<p>Username: <%= user.getUsername() %></p>

<ul>
    <li><a href="sellerShop.jsp">Manage Products</a></li>
    <li><a href="orders.jsp">View Orders</a></li>
    <li><a href="logout">Logout</a></li>
</ul>

</body>
</html>
