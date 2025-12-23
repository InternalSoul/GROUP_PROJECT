<%@ page import="java.util.*, model.*" %>
<%
    List<Product> cart =
        (List<Product>) session.getAttribute("cart");

    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute("cart", cart);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Cart</title>
</head>
<body>

<h2>Your Cart</h2>

<% if (cart.isEmpty()) { %>
    <p>Cart is empty</p>
    <a href="products.jsp">Go Back</a>
<% } else { %>

<table border="1">
<tr><th>Name</th><th>Price</th></tr>

<% double total = 0;
   for (Product p : cart) {
       total += p.getPrice(); %>
<tr>
    <td><%= p.getName() %></td>
    <td><%= p.getPrice() %></td>
</tr>
<% } %>

</table>

<p>Total: RM <%= total %></p>

<form action="order" method="post">
    <input type="hidden" name="price" value="<%= total %>">
    <button type="submit">Checkout</button>
</form>

<% } %>

</body>
</html>
