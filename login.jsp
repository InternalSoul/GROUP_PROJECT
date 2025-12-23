<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head><title>Login</title></head>
<body>
<h2>Login</h2>
<% if (request.getAttribute("error") != null) { %>
    <p style="color:red;"><%= request.getAttribute("error") %></p>
<% } %>
<form method="post" action="login">
    <input type="text" name="username" placeholder="Username" required/><br>
    <input type="password" name="password" placeholder="Password" required/><br>
    <button type="submit">Login</button>
</form>
<a href="register.jsp">Don't have an account? Register</a>
</body>
</html>
