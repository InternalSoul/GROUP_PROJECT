package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.List;
import model.*;

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Order order = (Order) session.getAttribute("order");
        if (order == null) {
            res.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        String method = req.getParameter("method");
        if (method == null || method.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/payment.jsp");
            return;
        }

        Payment payment;

        if ("Online".equalsIgnoreCase(method)) {
            OnlineBanking ob = new OnlineBanking();
            ob.setAmount(order.calcTotal());
            ob.setPaymentMethod("Online Banking");
            ob.setStatus("Completed");
            payment = ob;
        } else if ("Card".equalsIgnoreCase(method)) {
            OnlineBanking ob = new OnlineBanking();
            ob.setAmount(order.calcTotal());
            ob.setPaymentMethod("Credit/Debit Card");
            ob.setStatus("Completed");
            payment = ob;
        } else {
            Cash cash = new Cash();
            cash.setAmount(order.calcTotal());
            cash.setPaymentMethod("Cash on Delivery");
            cash.setStatus("Pending");
            payment = cash;
        }

        // Process payment
        payment.processPayment();

        // Update in-memory order status
        order.setStatus(payment.getStatus());

        // If the order was already created in DB during checkout,
        // just update its status instead of inserting a new row.
        Integer orderDbId = (Integer) session.getAttribute("orderDbId");
        if (orderDbId != null && orderDbId > 0) {
            try (Connection conn = DatabaseConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement("UPDATE orders SET status = ? WHERE id = ?")) {
                ps.setString(1, order.getStatus());
                ps.setInt(2, orderDbId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            // Fallback: if no existing DB order id, insert as before
            try (Connection conn = DatabaseConnection.getConnection()) {
                conn.setAutoCommit(false);

                String insertOrderSql = "INSERT INTO orders (user_username, total_amount, status, created_at) VALUES (?,?,?,NOW())";
                int orderId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    String username = (order.getUser() != null) ? order.getUser().getUsername() : null;
                    ps.setString(1, username);
                    ps.setDouble(2, order.calcTotal());
                    ps.setString(3, order.getStatus());
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            orderId = rs.getInt(1);
                        }
                    }
                }

                if (orderId > 0 && order.getOrderDetails() != null) {
                    String insertItemSql = "INSERT INTO order_items (order_id, product_id, product_name, seller_username, quantity, price) VALUES (?,?,?,?,?,?)";
                    try (PreparedStatement psItem = conn.prepareStatement(insertItemSql)) {
                        for (OrderDetails od : order.getOrderDetails()) {
                            Product p = od.getProduct();
                            psItem.setInt(1, orderId);
                            psItem.setInt(2, p != null ? p.getId() : 0);
                            psItem.setString(3, p != null ? p.getName() : null);
                            psItem.setString(4, p != null ? p.getSellerUsername() : null);
                            psItem.setInt(5, od.getQuantity());
                            psItem.setDouble(6, od.getPrice());
                            psItem.addBatch();
                        }
                        psItem.executeBatch();
                    }
                }

                conn.commit();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Redirect to tracking
        res.sendRedirect(req.getContextPath() + "/tracking");
    }
}
