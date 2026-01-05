<%@ page import="java.util.*, java.net.URLEncoder, com.mycompany.oscp.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    
    // Check for error message from cart operation
    String errorMsg = (String) session.getAttribute("error");
    if (errorMsg != null) {
        session.removeAttribute("error");
    }
    
    Product product = (Product) request.getAttribute("product");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    Double averageRating = (Double) request.getAttribute("averageRating");
    Integer reviewCount = (Integer) request.getAttribute("reviewCount");
    String description = (String) request.getAttribute("description");
    if (product == null) {
        response.sendRedirect("products");
        return;
    }
    if (reviews == null) { reviews = new ArrayList<>(); }
    if (averageRating == null) { averageRating = 0.0; }
    if (reviewCount == null) { reviewCount = 0; }
    if (description == null) { description = "This piece is crafted with attention to detail. Check specs below for sizing and materials."; }
    List<String> specs = new ArrayList<>();
    if (product.getProductType() != null && !product.getProductType().isEmpty()) specs.add("Type: " + product.getProductType());
    if (product.getBrand() != null && !product.getBrand().isEmpty()) specs.add("Brand: " + product.getBrand());
    if (product.getCategory() != null && !product.getCategory().isEmpty()) specs.add("Category: " + product.getCategory());
    if (product.getSize() != null && !product.getSize().isEmpty()) specs.add("Size: " + product.getSize());
    if (product.getColor() != null && !product.getColor().isEmpty()) specs.add("Color: " + product.getColor());
    if (product.getMaterial() != null && !product.getMaterial().isEmpty()) specs.add("Material: " + product.getMaterial());
    if (product.getStockQuantity() > 0) specs.add("Stock: " + product.getStockQuantity() + " pcs available");
    if (product.getCreatedAt() != null) specs.add("Listed on: " + product.getCreatedAt().toLocalDateTime().toLocalDate());

    // Variant data (per-seller availability for size/color) built in servlet.
    List<Product> variants = (List<Product>) request.getAttribute("variants");
    Set<String> variantSizes = new LinkedHashSet<>();
    Set<String> variantColors = new LinkedHashSet<>();
    Map<String, Boolean> sizeAvailable = new HashMap<>();
    Map<String, Boolean> colorAvailable = new HashMap<>();
    if (variants != null) {
        for (Product v : variants) {
            String vs = v.getSize();
            String vc = v.getColor();
            boolean avail = v.isInStock() && v.getStockQuantity() > 0;
            if (vs != null && !vs.isEmpty()) {
                variantSizes.add(vs);
                sizeAvailable.put(vs, sizeAvailable.containsKey(vs) ? (sizeAvailable.get(vs) || avail) : avail);
            }
            if (vc != null && !vc.isEmpty()) {
                variantColors.add(vc);
                colorAvailable.put(vc, colorAvailable.containsKey(vc) ? (colorAvailable.get(vc) || avail) : avail);
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getName() %> - Details</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;700&family=Manrope:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Manrope', sans-serif; background: linear-gradient(135deg, #f7f7f2, #f0f4ff); color: #0f172a; }
        .top-bar { background: #1a1a1a; color: #fff; text-align: center; padding: 10px; font-size: 0.85em; letter-spacing: 1px; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 20px 60px; border-bottom: 1px solid #eee; background: #fff; }
        .navbar .logo { font-family: 'Playfair Display', serif; font-size: 1.8em; font-weight: 700; letter-spacing: 3px; text-decoration: none; color: #1a1a1a; }
        .navbar .nav-links { display: flex; gap: 30px; align-items: center; }
        .navbar .nav-links a { text-decoration: none; color: #1a1a1a; font-size: 0.85em; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; transition: opacity 0.3s; }
        .navbar .nav-links a:hover { opacity: 0.6; }
        .cart-count { background: #1a1a1a; color: #fff; padding: 2px 8px; font-size: 0.75em; margin-left: 5px; }
        .user-name { color: #888; font-size: 0.85em; }
        .page { max-width: 1200px; margin: 40px auto 60px; padding: 0 40px; }
        .breadcrumbs { font-size: 0.85em; color: #475569; margin-bottom: 20px; }
        .layout { display: grid; grid-template-columns: 1.1fr 0.9fr; gap: 40px; align-items: start; }
        .media { background: #fff; border: 1px solid #e2e8f0; border-radius: 20px; padding: 20px; box-shadow: 0 12px 40px rgba(15, 23, 42, 0.05); }
        .hero-img { width: 100%; aspect-ratio: 4 / 5; background: #f1f5f9; border-radius: 12px; display: flex; align-items: center; justify-content: center; overflow: hidden; }
        .hero-img img { width: 100%; height: 100%; object-fit: cover; }
        .hero-placeholder { font-size: 4em; color: #cbd5e1; }
        .detail-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 20px; padding: 28px; box-shadow: 0 12px 40px rgba(15, 23, 42, 0.05); }
        .title { font-family: 'Cormorant Garamond', serif; font-size: 2.4em; letter-spacing: 1px; margin-bottom: 8px; }
        .meta { color: #475569; font-size: 0.95em; margin-bottom: 12px; }
        .seller-row { display: inline-flex; align-items: center; gap: 10px; }
        .seller-avatar { width: 40px; height: 40px; border-radius: 50%; border: 1px solid #e2e8f0; object-fit: cover; }
        .seller-link { display: inline-flex; align-items: center; gap: 10px; color: #0f172a; text-decoration: none; font-weight: 700; letter-spacing: 0.5px; }
        .seller-link:hover { text-decoration: underline; }
        .price { font-size: 1.8em; font-weight: 700; color: #0f172a; margin: 14px 0 6px; }
        .stock-row { display:flex; align-items:center; gap:10px; margin-bottom: 12px; font-size:0.9em; color:#475569; }
        .stock-pill { padding:4px 10px; border-radius:999px; font-size:0.75em; letter-spacing:0.5px; text-transform:uppercase; }
        .stock-pill.in { background:#ecfdf3; color:#166534; border:1px solid #bbf7d0; }
        .stock-pill.out { background:#fef2f2; color:#b91c1c; border:1px solid #fecaca; }
        .badges { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 12px; }
        .badge { padding: 6px 10px; border-radius: 999px; font-size: 0.75em; letter-spacing: 0.5px; text-transform: uppercase; }
        .badge-dark { background: #0f172a; color: #fff; }
        .badge-outline { border: 1px solid #0f172a; color: #0f172a; background: #fff; }
        .rating { display: flex; align-items: center; gap: 8px; color: #f59e0b; font-weight: 700; margin-bottom: 10px; }
        .rating span { color: #0f172a; font-weight: 600; }
        .desc { color: #1e293b; line-height: 1.6; margin: 12px 0 20px; }
        .actions { display: flex; gap: 12px; margin-top: 16px; flex-wrap: wrap; }
        .btn { border: none; cursor: pointer; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; border-radius: 10px; padding: 14px 18px; transition: transform 0.2s, box-shadow 0.2s; }
        .btn-primary { background: #0f172a; color: #fff; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.2); }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 16px 36px rgba(15, 23, 42, 0.25); }
        .btn-ghost { background: transparent; border: 1px solid #0f172a; color: #0f172a; }
        .specs { margin-top: 28px; }
        .spec-title { font-size: 0.95em; font-weight: 700; letter-spacing: 1px; color: #475569; margin-bottom: 10px; text-transform: uppercase; }
        .spec-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; }
        .spec-chip { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px; font-size: 0.95em; color: #0f172a; }
        .section { background: #fff; border: 1px solid #e2e8f0; border-radius: 18px; padding: 24px; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04); margin-top: 30px; }
        .section h2 { font-family: 'Cormorant Garamond', serif; font-size: 1.8em; margin-bottom: 10px; }
        .section p { color: #1e293b; line-height: 1.6; }
        .reviews { display: grid; gap: 14px; margin-top: 16px; }
        .review { border: 1px solid #e2e8f0; border-radius: 14px; padding: 14px; background: #f8fafc; }
        .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; color: #475569; font-size: 0.9em; }
        .review-rating { color: #f59e0b; font-weight: 700; }
        .review-comment { color: #0f172a; line-height: 1.5; }
        .empty { padding: 18px; border: 1px dashed #cbd5e1; border-radius: 10px; color: #475569; background: #f8fafc; }
        .variant-pill { padding: 8px 12px; border-radius: 999px; border: 1px solid #e2e8f0; background: #f8fafc; font-size: 0.9em; cursor: pointer; }
        .variant-pill-selected { border-color: #0f172a; background: #0f172a; color: #fff; }
        .variant-pill[disabled] { opacity: 0.4; cursor: not-allowed; background: #f1f5f9; }
        @media (max-width: 1024px) { 
            .layout { grid-template-columns: 1fr; } 
            .navbar { padding: 16px 30px; flex-wrap: wrap; } 
            .navbar .nav-links { gap: 15px; flex-wrap: wrap; }
            .page { padding: 0 24px; } 
        }
        @media (max-width: 768px) {
            .navbar { padding: 12px 20px; }
            .navbar .logo { font-size: 1.4em; }
            .navbar .nav-links { font-size: 0.75em; gap: 12px; }
            .page { padding: 0 20px; margin: 30px auto 40px; }
            .title { font-size: 2em; }
            .price { font-size: 1.5em; }
            .layout { gap: 20px; }
            .media, .detail-card { padding: 16px; }
            .spec-grid { grid-template-columns: 1fr; }
            .actions { flex-direction: column; }
            .actions .btn { width: 100%; }
        }
        @media (max-width: 480px) {
            .breadcrumbs { font-size: 0.75em; }
            .title { font-size: 1.6em; }
            .hero-img { aspect-ratio: 3 / 4; }
            .section { padding: 16px; }
            .section h2 { font-size: 1.5em; }
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="page">
        <div class="breadcrumbs"><a href="products" style="color:#0f172a; text-decoration:none;">Shop</a> / <span style="opacity:0.65;"><%= product.getName() %></span></div>
        
        <% if (errorMsg != null) { %>
        <div style="background:#fef2f2; border:1px solid #fecaca; color:#b91c1c; padding:14px 18px; border-radius:10px; margin-bottom:20px; font-size:0.95em;">
            <%= errorMsg %>
        </div>
        <% } %>
        
        <div class="layout">
            <div class="media">
                <div class="hero-img">
                    <% if (product.getImage() != null && !product.getImage().isEmpty()) { %>
                        <img src="<%= product.getImage() %>" alt="<%= product.getName() %>">
                    <% } else { %>
                        <span class="hero-placeholder">◇</span>
                    <% } %>
                </div>
            </div>
            <div class="detail-card">
                <h1 class="title"><%= product.getName() %></h1>
                <div class="meta">
                    <% String sellerName = product.getSellerUsername() != null && !product.getSellerUsername().isEmpty() ? product.getSellerUsername() : "Unknown"; %>
                    <% String sellerUrl = "sellerStore.jsp?seller=" + URLEncoder.encode(sellerName, "UTF-8"); %>
                    <% String avatarUrl = "https://ui-avatars.com/api/?background=111111&color=fff&name=" + URLEncoder.encode(sellerName, "UTF-8"); %>
                    <a class="seller-link" href="<%= sellerUrl %>">
                        <img class="seller-avatar" src="<%= avatarUrl %>" alt="<%= sellerName %>">
                        <span><%= sellerName %></span>
                    </a>
                </div>
                <div class="rating">★ <%= String.format("%.1f", averageRating) %> <span>(<%= reviewCount %> reviews)</span></div>
                <div class="price">$<%= String.format("%.2f", product.getPrice()) %></div>
                <% if (product.getStockQuantity() > 0) { %>
                    <div style="font-size:0.95em; color:#475569; margin-bottom:4px;">
                        <%= product.getStockQuantity() %> pieces available
                    </div>
                <% } %>
                <div class="stock-row">
                    <% if (product.isInStock()) { %>
                        <span class="stock-pill in">In Stock</span>
                    <% } else { %>
                        <span class="stock-pill out">Out of Stock</span>
                    <% } %>
                </div>
                <p class="desc"><%= description %></p>
                <div class="actions">
                    <button type="button" id="openAddToCart" class="btn btn-primary">Add to Cart</button>
                    <a href="products" class="btn btn-ghost" style="text-decoration:none; display:inline-flex; align-items:center;">Back to Shop</a>
                </div>

                <div class="specs">
                    <div class="spec-title">Key Specs</div>
                    <% if (specs.isEmpty()) { %>
                        <div class="empty">No specs provided for this item yet.</div>
                    <% } else { %>
                        <div class="spec-grid">
                            <% for (String s : specs) { %>
                                <div class="spec-chip"><%= s %></div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="section" style="margin-top: 32px;">
            <h2>Reviews</h2>
            <p>See what shoppers say about this piece.</p>
            <% if (reviews.isEmpty()) { %>
                <div class="empty" style="margin-top:12px;">No reviews yet. Be the first to share your thoughts.</div>
            <% } else { %>
                <div class="reviews">
                    <% for (Review r : reviews) { %>
                        <div class="review">
                            <div class="review-header">
                                <span><%= r.getUsername() != null && !r.getUsername().isEmpty() ? r.getUsername() : "Verified buyer" %></span>
                                <span class="review-rating">★ <%= r.getRating() %></span>
                            </div>
                            <% if (r.getCreatedAt() != null) { %>
                                <div style="color:#94a3b8; font-size:0.85em; margin-bottom:6px;">Posted on <%= r.getCreatedAt().toLocalDateTime().toLocalDate() %></div>
                            <% } %>
                            <div class="review-comment"><%= r.getComment() != null && !r.getComment().isEmpty() ? r.getComment() : "No comment provided." %></div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Add to Cart Modal -->
    <div id="addToCartOverlay" style="position:fixed; inset:0; background:rgba(15,23,42,0.55); display:none; align-items:center; justify-content:center; z-index:50;">
        <div style="background:#fff; border-radius:18px; max-width:480px; width:100%; padding:24px 24px 28px; box-shadow:0 20px 60px rgba(15,23,42,0.35); position:relative;">
            <button type="button" id="closeAddToCart" style="position:absolute; top:14px; right:16px; border:none; background:transparent; font-size:1.2em; cursor:pointer;">×</button>
            <h2 style="font-family:'Cormorant Garamond', serif; font-size:1.8em; margin-bottom:8px;">Add to Cart</h2>
            <p style="color:#64748b; font-size:0.9em; margin-bottom:18px;">Choose any add-ons and quantity, then confirm.</p>

            <form id="addToCartForm" action="cart" method="post" style="display:flex; flex-direction:column; gap:16px;">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="id" value="<%= product.getId() %>">
                <input type="hidden" name="name" value="<%= product.getName() %>">
                <input type="hidden" name="price" id="unitPriceInput" value="<%= product.getPrice() %>">
                <input type="hidden" name="image" value="<%= (product.getImage() != null ? product.getImage() : "") %>">
                <input type="hidden" name="sellerUsername" value="<%= product.getSellerUsername() != null ? product.getSellerUsername() : "" %>">

                <div>
                    <div style="font-size:0.8em; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#94a3b8; margin-bottom:8px;">Base Price</div>
                    <div style="font-size:1.1em; font-weight:600;">$<span id="basePriceDisplay"><%= String.format("%.2f", product.getPrice()) %></span></div>
                </div>

                <%
                    // Fallbacks: if no variant list from DB, try to use the product's own size/color
                    boolean hasVariantSizes = !variantSizes.isEmpty();
                    boolean hasVariantColors = !variantColors.isEmpty();

                    List<String> fallbackSizes = new ArrayList<>();
                    if (!hasVariantSizes && product.getSize() != null && !product.getSize().isEmpty()) {
                        String[] parts = product.getSize().split("[, ]+");
                        for (String p : parts) {
                            if (!p.isEmpty()) { fallbackSizes.add(p); }
                        }
                    }
                    boolean showSizeSection = hasVariantSizes || !fallbackSizes.isEmpty();

                    List<String> fallbackColors = new ArrayList<>();
                    if (!hasVariantColors && product.getColor() != null && !product.getColor().isEmpty()) {
                        String[] partsC = product.getColor().split("[, ]+");
                        for (String p : partsC) {
                            if (!p.isEmpty()) { fallbackColors.add(p); }
                        }
                    }
                    boolean showColorSection = hasVariantColors || !fallbackColors.isEmpty();
                %>

                <!-- Size options (variants if available, otherwise fallback to product size field) -->
                <% if (showSizeSection) { %>
                <div>
                    <div style="font-size:0.8em; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#94a3b8; margin-bottom:8px;">Size</div>
                    <div style="display:flex; flex-wrap:wrap; gap:8px;" id="sizeOptions">
                        <% if (hasVariantSizes) { %>
                            <% for (String s : variantSizes) { boolean avail = Boolean.TRUE.equals(sizeAvailable.get(s)); %>
                                <button type="button" class="variant-pill" data-variant-type="size" data-value="<%= s %>" <%= avail ? "" : "disabled" %>><%= s %></button>
                            <% } %>
                        <% } else { %>
                            <% for (String s : fallbackSizes) { boolean avail = product.isInStock() && product.getStockQuantity() > 0; %>
                                <button type="button" class="variant-pill" data-variant-type="size" data-value="<%= s %>" <%= avail ? "" : "disabled" %>><%= s %></button>
                            <% } %>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <!-- Color options (variants if available, otherwise fallback to product color field) -->
                <% if (showColorSection) { %>
                <div>
                    <div style="font-size:0.8em; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#94a3b8; margin-bottom:8px;">Color</div>
                    <div style="display:flex; flex-wrap:wrap; gap:8px;" id="colorOptions">
                        <% if (hasVariantColors) { %>
                            <% for (String c : variantColors) { boolean avail = Boolean.TRUE.equals(colorAvailable.get(c)); %>
                                <button type="button" class="variant-pill" data-variant-type="color" data-value="<%= c %>" <%= avail ? "" : "disabled" %>><%= c %></button>
                            <% } %>
                        <% } else { %>
                            <% for (String c : fallbackColors) { boolean avail = product.isInStock() && product.getStockQuantity() > 0; %>
                                <button type="button" class="variant-pill" data-variant-type="color" data-value="<%= c %>" <%= avail ? "" : "disabled" %>><%= c %></button>
                            <% } %>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <div>
                    <div style="font-size:0.8em; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#94a3b8; margin-bottom:8px;">Add-ons</div>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <label style="display:flex; justify-content:space-between; align-items:center; gap:8px; padding:10px 12px; border-radius:10px; border:1px solid #e2e8f0; cursor:pointer;">
                            <span style="font-size:0.9em;">No add-ons</span>
                            <span style="font-size:0.85em; color:#64748b;">+$0.00</span>
                            <input type="radio" name="addonOption" value="none" data-extra="0" checked style="margin-left:8px;">
                        </label>
                        <label style="display:flex; justify-content:space-between; align-items:center; gap:8px; padding:10px 12px; border-radius:10px; border:1px solid #e2e8f0; cursor:pointer;">
                            <span style="font-size:0.9em;">Gift wrap</span>
                            <span style="font-size:0.85em; color:#64748b;">+&dollar;5.00</span>
                            <input type="radio" name="addonOption" value="giftwrap" data-extra="5" style="margin-left:8px;">
                        </label>
                        <label style="display:flex; justify-content:space-between; align-items:center; gap:8px; padding:10px 12px; border-radius:10px; border:1px solid #e2e8f0; cursor:pointer;">
                            <span style="font-size:0.9em;">Premium care package</span>
                            <span style="font-size:0.85em; color:#64748b;">+&dollar;15.00</span>
                            <input type="radio" name="addonOption" value="premium" data-extra="15" style="margin-left:8px;">
                        </label>
                    </div>
                </div>

                <div style="display:flex; justify-content:space-between; align-items:center; gap:16px;">
                    <div>
                        <div style="font-size:0.8em; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#94a3b8; margin-bottom:6px;">Quantity</div>
                        <input type="number" name="quantity" id="quantityInput" value="1" min="1" style="width:80px; padding:8px 10px; border-radius:8px; border:1px solid #e2e8f0; font-size:0.95em;">
                    </div>
                    <div style="text-align:right;">
                        <div style="font-size:0.8em; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#94a3b8; margin-bottom:6px;">Estimated Total</div>
                        <div style="font-size:1.2em; font-weight:700;">$<span id="totalPriceDisplay"><%= String.format("%.2f", product.getPrice()) %></span></div>
                        <div style="font-size:0.8em; color:#94a3b8;">Per item: $<span id="unitPriceDisplay"><%= String.format("%.2f", product.getPrice()) %></span></div>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%; justify-content:center; margin-top:6px;">Confirm & Add to Cart</button>
            </form>
        </div>
    </div>
</body>
<script>
    (function() {
        const overlay = document.getElementById('addToCartOverlay');
        const openBtn = document.getElementById('openAddToCart');
        const closeBtn = document.getElementById('closeAddToCart');
        const quantityInput = document.getElementById('quantityInput');
        const addonOptions = document.querySelectorAll('input[name="addonOption"]');
        const totalPriceDisplay = document.getElementById('totalPriceDisplay');
        const unitPriceDisplaySpan = document.getElementById('unitPriceDisplay');
        const unitPriceInput = document.getElementById('unitPriceInput');
        const basePriceDisplaySpan = document.getElementById('basePriceDisplay');
        const productIdInput = document.querySelector('#addToCartForm input[name="id"]');
        const imageInput = document.querySelector('#addToCartForm input[name="image"]');

        const sizeButtons = document.querySelectorAll('#sizeOptions .variant-pill');
        const colorButtons = document.querySelectorAll('#colorOptions .variant-pill');

        // Variant data for size/color combinations and availability
        const variants = [
        <% if (variants != null) { for (int i = 0; i < variants.size(); i++) { Product v = variants.get(i); %>
            {
                id: <%= v.getId() %>,
                size: "<%= v.getSize() != null ? v.getSize() : "" %>",
                color: "<%= v.getColor() != null ? v.getColor() : "" %>",
                price: <%= v.getPrice() %>,
                image: "<%= v.getImage() != null ? v.getImage() : "" %>",
                inStock: <%= v.isInStock() %>,
                stock: <%= v.getStockQuantity() %>
            }<%= (i < variants.size() - 1 ? "," : "") %>
        <% } } %>
        ];

        let selectedSize = null;
        let selectedColor = null;
        let currentVariant = null;

        function pickDefaultVariant() {
            if (variants.length === 0) {
                currentVariant = {
                    id: <%= product.getId() %>,
                    size: "<%= product.getSize() != null ? product.getSize() : "" %>",
                    color: "<%= product.getColor() != null ? product.getColor() : "" %>",
                    price: <%= product.getPrice() %>,
                    image: "<%= product.getImage() != null ? product.getImage() : "" %>",
                    inStock: <%= product.isInStock() %>,
                    stock: <%= product.getStockQuantity() %>
                };
                return;
            }
            // Prefer the actual product id as the default variant if present
            currentVariant = variants.find(v => v.id === <%= product.getId() %>) || variants[0];
            selectedSize = currentVariant.size || null;
            selectedColor = currentVariant.color || null;
        }

        function updateVariantSelectionClasses() {
            sizeButtons.forEach(btn => {
                btn.classList.remove('variant-pill-selected');
                if (selectedSize && btn.getAttribute('data-value') === selectedSize) {
                    btn.classList.add('variant-pill-selected');
                }
            });
            colorButtons.forEach(btn => {
                btn.classList.remove('variant-pill-selected');
                if (selectedColor && btn.getAttribute('data-value') === selectedColor) {
                    btn.classList.add('variant-pill-selected');
                }
            });
        }

        function recalcCurrentVariant() {
            if (variants.length === 0) {
                return;
            }
            let candidate = variants.slice();
            if (selectedSize) {
                candidate = candidate.filter(v => v.size === selectedSize);
            }
            if (selectedColor) {
                candidate = candidate.filter(v => v.color === selectedColor);
            }
            if (candidate.length === 0) {
                candidate = variants;
            }
            currentVariant = candidate[0];
        }

        function applyCurrentVariant() {
            if (!currentVariant) return;
            productIdInput.value = currentVariant.id;
            if (currentVariant.image) {
                imageInput.value = currentVariant.image;
            }
            basePriceDisplaySpan.textContent = currentVariant.price.toFixed(2);
        }

        function currentExtra() {
            let extra = 0;
            addonOptions.forEach(function(opt) {
                if (opt.checked) {
                    extra = parseFloat(opt.getAttribute('data-extra')) || 0;
                }
            });
            return extra;
        }

        function updatePrices() {
            const basePrice = currentVariant ? currentVariant.price : parseFloat('<%= product.getPrice() %>');
            const extra = currentExtra();
            const qty = Math.max(1, parseInt(quantityInput.value || '1', 10));
            const unit = basePrice + extra;
            const total = unit * qty;

            unitPriceDisplaySpan.textContent = unit.toFixed(2);
            totalPriceDisplay.textContent = total.toFixed(2);
            unitPriceInput.value = unit.toFixed(2);
        }

        // Wire up size/color selection
        sizeButtons.forEach(btn => {
            btn.addEventListener('click', function() {
                if (btn.disabled) return;
                selectedSize = btn.getAttribute('data-value');
                updateVariantSelectionClasses();
                recalcCurrentVariant();
                applyCurrentVariant();
                updatePrices();
            });
        });

        colorButtons.forEach(btn => {
            btn.addEventListener('click', function() {
                if (btn.disabled) return;
                selectedColor = btn.getAttribute('data-value');
                updateVariantSelectionClasses();
                recalcCurrentVariant();
                applyCurrentVariant();
                updatePrices();
            });
        });

        if (openBtn) {
            openBtn.addEventListener('click', function() {
                overlay.style.display = 'flex';
                // Ensure a variant is picked before first open
                if (!currentVariant) {
                    pickDefaultVariant();
                    updateVariantSelectionClasses();
                    applyCurrentVariant();
                }
                updatePrices();
            });
        }
        if (closeBtn) {
            closeBtn.addEventListener('click', function() {
                overlay.style.display = 'none';
            });
        }
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                overlay.style.display = 'none';
            }
        });

        addonOptions.forEach(function(opt) {
            opt.addEventListener('change', updatePrices);
        });
        quantityInput.addEventListener('input', updatePrices);

        // Initialize variant and pricing for first load
        pickDefaultVariant();
        updateVariantSelectionClasses();
        applyCurrentVariant();
        updatePrices();
    })();
</script>
</html>
