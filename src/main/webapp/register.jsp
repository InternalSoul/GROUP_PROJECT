<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - DormDealz</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #fafafa; min-height: 100vh; display: flex; flex-direction: column; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; background: #fff; border-bottom: 1px solid #eee; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.9em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; margin-left: 30px; }
        .main-content { flex: 1; display: flex; justify-content: center; align-items: center; padding: 60px 20px; }
        .register-container { background: #fff; padding: 60px; width: 100%; max-width: 500px; border: 1px solid #e5e5e5; }
        h2 { font-family: 'Playfair Display', serif; font-size: 2em; font-weight: 400; text-align: center; margin-bottom: 10px; letter-spacing: 2px; }
        .subtitle { text-align: center; color: #888; font-size: 0.9em; margin-bottom: 40px; }
        .form-group { margin-bottom: 22px; }
        label { display: block; margin-bottom: 10px; color: #1a1a1a; font-size: 0.8em; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; }
        input[type="text"], input[type="email"], input[type="password"], select, textarea { width: 100%; padding: 16px; border: 1px solid #ddd; font-size: 1em; font-family: 'Inter', sans-serif; transition: border-color 0.3s; }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #1a1a1a; }
        select { cursor: pointer; background: white; }
        .btn { width: 100%; padding: 18px; background: #1a1a1a; color: #fff; border: none; font-size: 0.85em; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; transition: background 0.3s; }
        .btn:hover { background: #333; }
        .error { background: #fff5f5; color: #c53030; padding: 15px; margin-bottom: 25px; text-align: center; font-size: 0.9em; border: 1px solid #fed7d7; }
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
        <a href="index.jsp" class="logo">DORMDEALZ</a>
        <div class="nav-links"><a href="login">Login</a></div>
    </nav>
    <div class="main-content">
        <div class="register-container">
            <h2>Create Account</h2>
            <p class="subtitle">Join our community today</p>
            <% if (request.getAttribute("error") != null) { %><div class="error"><%= request.getAttribute("error") %></div><% } %>
            <form method="post" action="register">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="Choose a username" required>
                </div>
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" placeholder="Enter your email" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Create a password" required>
                </div>
                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea id="address" name="address" rows="2" placeholder="Enter your address"></textarea>
                </div>
                <div class="form-group">
                    <label for="role">Account Type</label>
                    <select id="role" name="role">
                        <option value="customer">Customer</option>
                        <option value="seller">Seller</option>
                    </select>
                </div>
                <button type="submit" class="btn">Create Account</button>
            </form>
            <div class="links">
                <p>Already have an account? <a href="login">Sign in</a></p>
                <p><a href="index.jsp">← Back to Home</a></p>
            </div>
        </div>
    </div>
    <footer class="footer"><p>© 2026 DormDealz. All rights reserved.</p></footer>
</body>
</html>
