<%@ page import="java.util.*, model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"seller".equals(user.getRole())) {
        response.sendRedirect("login");
        return;
    }

    List<Product> products =
        (List<Product>) application.getAttribute("products");

    if (products == null) {
        products = new ArrayList<>();
        application.setAttribute("products", products);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Seller Shop</title>
</head>
<body>

<h2>Seller Shop Page</h2>

<h3>Add Product</h3>
<form action="products" method="post">
    Name: <input type="text" name="name" required>
    Price: <input type="number" name="price" required>
    <button type="submit">Add</button>
</form>

<hr>

<h3>Product List</h3>
<table border="1">
<tr>
    <th>Name</th><th>Price</th><th>Action</th>
</tr>

<% for (int i = 0; i < products.size(); i++) { %>
<tr>
    <td><%= products.get(i).getName() %></td>
    <td><%= products.get(i).getPrice() %></td>
    <td>
        <form action="products" method="post" style="display:inline;">
            <input type="hidden" name="index" value="<%= i %>">
            <input type="hidden" name="action" value="delete">
            <button type="submit">Delete</button>
        </form>
    </td>
</tr>
<% } %>

</table>

</body>
</html>
