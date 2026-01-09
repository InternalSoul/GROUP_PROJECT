<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Clothing Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; display: flex; flex-direction: column; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; background: #fff; border-bottom: 1px solid #eee; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.9em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-left: 30px; }
        .main-content { flex: 1; display: flex; justify-content: center; align-items: center; padding: 60px 20px; }
        .login-container { background: #fff; padding: 60px; width: 100%; max-width: 450px; border: 1px solid #e5e5e5; }
        h2 { font-family: 'Playfair Display', serif; font-size: 2em; font-weight: 400; text-align: center; margin-bottom: 10px; letter-spacing: 2px; }
        .subtitle { text-align: center; color: #888; font-size: 0.9em; margin-bottom: 40px; }
        .form-group { margin-bottom: 25px; }
        label { display: block; margin-bottom: 10px; color: #1a1a1a; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; }
        input[type="text"], input[type="password"] { width: 100%; padding: 16px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; transition: border-color 0.3s; }
        input[type="text"]:focus, input[type="password"]:focus { outline: none; border-color: #1a1a1a; }
        .btn { width: 100%; padding: 18px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .btn:hover { background: #333; }
        .error { background: #fff5f5; color: #c53030; padding: 15px; margin-bottom: 25px; text-align: center; font-size: 0.9em; border: 1px solid #fed7d7; }
        .success { background: #f0fff4; color: #276749; padding: 15px; margin-bottom: 25px; text-align: center; font-size: 0.9em; border: 1px solid #c6f6d5; }
        .links { text-align: center; margin-top: 30px; padding-top: 30px; border-top: 1px solid #eee; }
        .links p { color: #666; font-size: 0.9em; margin-bottom: 10px; }
        .links a { color: #1a1a1a; text-decoration: none; font-weight: 500; }
        .links a:hover { text-decoration: underline; }
        .footer { background: #1a1a1a; color: #fff; padding: 30px; text-align: center; }
        .footer p { color: #666; font-size: 0.8em; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="index.jsp" class="logo">CLOTHING STORE</a>
        <div class="nav-links"><a href="register">Register</a></div>
    </nav>
    <div class="main-content">
        <div class="login-container">
            <h2>Welcome Back</h2>
            <p class="subtitle">Sign in to your account</p>
            <% if (request.getAttribute("error") != null) { %><div class="error"><%= request.getAttribute("error") %></div><% } %>
            <% if (request.getAttribute("success") != null) { %><div class="success"><%= request.getAttribute("success") %></div><% } %>
            <form method="post" action="login">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="Enter your username" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                </div>
                <button type="submit" class="btn">Sign In</button>
            </form>
            <div class="links">
                <p>Don't have an account? <a href="register">Create one</a></p>
                <p><a href="index.jsp">← Back to Home</a></p>
            </div>
        </div>
    </div>
    <footer class="footer"><p>© 2026 Clothing Store. All rights reserved.</p></footer>
</body>
</html>
