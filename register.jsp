<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head><title>Register</title></head>
<body>
<h2>Register</h2>
<% if (request.getAttribute("error") != null) { %>
    <p style="color:red;"><%= request.getAttribute("error") %></p>
<% } %>
<form method="post" action="register">
    <input type="text" name="username" placeholder="Username" required/><br>
    <input type="email" name="email" placeholder="Email" required/><br>
    <input type="password" name="password" placeholder="Password" required/><br>
    <input type="text" name="address" placeholder="Address" required/><br>
    <select name="role">
        <option value="customer">Customer</option>
        <option value="seller">Seller</option>
    </select><br>
    <button type="submit">Register</button>
</form>
<a href="login.jsp">Already have an account? Login</a>
</body>
</html>
