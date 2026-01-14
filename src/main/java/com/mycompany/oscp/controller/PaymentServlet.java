package com.mycompany.oscp.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import com.mycompany.oscp.model.*;

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
        Integer orderDbId = (Integer) session.getAttribute("orderDbId");
        if (order == null) {
            // Attempt to reload order from DB if we have an orderDbId
            if (orderDbId != null && orderDbId > 0) {
                try (Connection conn = DatabaseConnection.getConnection();
                        PreparedStatement ps = conn.prepareStatement(
                                "SELECT user_username, total_amount, status, payment_method FROM orders WHERE id = ?")) {
                    ps.setInt(1, orderDbId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            order = new Order();
                            order.setId(orderDbId);
                            order.setStatus(rs.getString("status"));
                            order.setPaymentMethod(rs.getString("payment_method"));

                            // Attach a minimal User object with username if desired
                            String username = rs.getString("user_username");
                            if (username != null) {
                                User u = new User();
                                u.setUsername(username);
                                order.setUser(u);
                            }

                            // Store back in session for later use
                            session.setAttribute("order", order);
                        } else {
                            res.sendRedirect(req.getContextPath() + "/cart");
                            return;
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    res.sendRedirect(req.getContextPath() + "/cart");
                    return;
                }
            } else {
                res.sendRedirect(req.getContextPath() + "/cart");
                return;
            }
        }

        String method = req.getParameter("method");
        if (method == null || method.isEmpty()) {
            req.setAttribute("error", "Please select a payment method");
            req.getRequestDispatcher("/payment.jsp").forward(req, res);
            return;
        }

        // Validate payment details based on method
        if ("Card".equalsIgnoreCase(method)) {
            String cardNumber = req.getParameter("cardNumber");
            String cardName = req.getParameter("cardName");
            String expiryDate = req.getParameter("expiryDate");
            String cvv = req.getParameter("cvv");

            if (cardNumber == null || cardNumber.isEmpty() ||
                    cardName == null || cardName.isEmpty() ||
                    expiryDate == null || expiryDate.isEmpty() ||
                    cvv == null || cvv.isEmpty()) {
                req.setAttribute("error", "Please fill in all card details");
                req.getRequestDispatcher("/payment.jsp").forward(req, res);
                return;
            }

            // Basic card number validation (16 digits)
            if (!cardNumber.matches("\\d{16}")) {
                req.setAttribute("error", "Invalid card number. Must be 16 digits");
                req.getRequestDispatcher("/payment.jsp").forward(req, res);
                return;
            }

            // CVV validation (3-4 digits)
            if (!cvv.matches("\\d{3,4}")) {
                req.setAttribute("error", "Invalid CVV. Must be 3-4 digits");
                req.getRequestDispatcher("/payment.jsp").forward(req, res);
                return;
            }
        } else if ("Online".equalsIgnoreCase(method)) {
            String bankName = req.getParameter("bankName");
            String accountNumber = req.getParameter("accountNumber");

            if (bankName == null || bankName.isEmpty() ||
                    accountNumber == null || accountNumber.isEmpty()) {
                req.setAttribute("error", "Please provide bank details");
                req.getRequestDispatcher("/payment.jsp").forward(req, res);
                return;
            }
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

        // Map to payments table values
        String paymentMethodDb = "cash";
        if ("Online".equalsIgnoreCase(method) || "Card".equalsIgnoreCase(method)) {
            paymentMethodDb = "online";
        }

        String paymentStatusDb;
        if ("Completed".equalsIgnoreCase(payment.getStatus())) {
            paymentStatusDb = "completed";
        } else if ("Failed".equalsIgnoreCase(payment.getStatus())) {
            paymentStatusDb = "failed";
        } else {
            paymentStatusDb = "pending";
        }

        // If the order was already created in DB during checkout,
        // just update its status instead of inserting a new row.
        if (orderDbId != null && orderDbId > 0) {
            try (Connection conn = DatabaseConnection.getConnection();
                    PreparedStatement psOrder = conn
                            .prepareStatement("UPDATE orders SET status = ?, payment_method = ? WHERE id = ?");
                    PreparedStatement psPayment = conn.prepareStatement(
                            "INSERT INTO payments (order_id, payment_method, amount, status, paid_at) VALUES (?,?,?,?,?)",
                            Statement.RETURN_GENERATED_KEYS)) {

                conn.setAutoCommit(false);

                // Update order row
                psOrder.setString(1, order.getStatus());
                psOrder.setString(2, paymentMethodDb);
                psOrder.setInt(3, orderDbId);
                psOrder.executeUpdate();

                // Insert into payments table
                psPayment.setInt(1, orderDbId);
                psPayment.setString(2, paymentMethodDb);
                psPayment.setDouble(3, order.calcTotal());
                psPayment.setString(4, paymentStatusDb);
                if ("completed".equals(paymentStatusDb)) {
                    psPayment.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
                } else {
                    psPayment.setTimestamp(5, null);
                }
                psPayment.executeUpdate();

                conn.commit();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            // Redirect to tracking page for this specific order
            res.sendRedirect(req.getContextPath() + "/tracking?orderId=" + orderDbId);
            return;
        } else {
            // Fallback: if no existing DB order id, insert as before
            try (Connection conn = DatabaseConnection.getConnection()) {
                conn.setAutoCommit(false);

                String insertOrderSql = "INSERT INTO orders (user_username, total_amount, status, payment_method, created_at) VALUES (?,?,?,?,NOW())";
                int orderId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    User user = (User) session.getAttribute("user");
                    String username = (order.getUser() != null) ? order.getUser().getUsername()
                            : (user != null ? user.getUsername() : null);
                    ps.setString(1, username);
                    ps.setDouble(2, order.calcTotal());
                    ps.setString(3, order.getStatus());
                    ps.setString(4, paymentMethodDb);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            orderId = rs.getInt(1);
                        }
                    }
                }

                // Insert into payments table for this order
                if (orderId > 0) {
                    String insertPaymentSql = "INSERT INTO payments (order_id, payment_method, amount, status, paid_at) VALUES (?,?,?,?,?)";
                    try (PreparedStatement psPay = conn.prepareStatement(insertPaymentSql)) {
                        psPay.setInt(1, orderId);
                        psPay.setString(2, paymentMethodDb);
                        psPay.setDouble(3, order.calcTotal());
                        psPay.setString(4, paymentStatusDb);
                        if ("completed".equals(paymentStatusDb)) {
                            psPay.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
                        } else {
                            psPay.setTimestamp(5, null);
                        }
                        psPay.executeUpdate();
                    }
                }

                if (orderId > 0 && order.getOrderDetails() != null) {
                    String insertItemSql = "INSERT INTO order_items (order_id, product_id, product_name, seller_username, quantity, price) VALUES (?,?,?,?,?,?)";
                    String sellerLookupSql = "SELECT seller_username FROM products WHERE product_id = ?";
                    try (PreparedStatement psItem = conn.prepareStatement(insertItemSql);
                            PreparedStatement psSeller = conn.prepareStatement(sellerLookupSql)) {
                        for (OrderDetails od : order.getOrderDetails()) {
                            Product p = od.getProduct();

                            String sellerUsername = null;
                            if (p != null) {
                                psSeller.setInt(1, p.getId());
                                try (ResultSet rsSeller = psSeller.executeQuery()) {
                                    if (rsSeller.next()) {
                                        sellerUsername = rsSeller.getString("seller_username");
                                    }
                                }
                            }

                            psItem.setInt(1, orderId);
                            psItem.setInt(2, p != null ? p.getId() : 0);
                            psItem.setString(3, p != null ? p.getName() : null);
                            psItem.setString(4, sellerUsername);
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
            // Redirect to tracking page for the newly created order
            // (fallback path when no orderDbId was present in the session)
            // orderId is available only inside the try-with-resources block, so fetch it
            // again.
            try (Connection conn = DatabaseConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement(
                            "SELECT id FROM orders WHERE user_username = ? ORDER BY created_at DESC LIMIT 1")) {
                User user = (User) session.getAttribute("user");
                ps.setString(1, user != null ? user.getUsername() : null);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int latestId = rs.getInt("id");
                        res.sendRedirect(req.getContextPath() + "/tracking?orderId=" + latestId);
                        return;
                    }
                }
            } catch (SQLException ignored) {
            }
        }
        // Fallback redirect if we couldn't determine a specific order id
        res.sendRedirect(req.getContextPath() + "/tracking");
    }
}
