package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import model.*;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        @SuppressWarnings("unchecked")
        List<Product> cart = (List<Product>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        try {
            // Calculate total
            double total = 0;
            for (Product p : cart) {
                total += p.getPrice();
            }

            // Create Order object
            Order order = new Order();
            order.setStatus("Pending");

            // Create OrderDetails list
            List<OrderDetails> detailsList = new ArrayList<>();
            for (Product p : cart) {
                OrderDetails od = new OrderDetails(1, p.getPrice(), p);
                detailsList.add(od);
            }
            order.setOrderDetails(detailsList);

            // Store order in session
            session.setAttribute("order", order);
            session.setAttribute("orderTotal", total);

            // Generate order ID
            String orderId = "ORD" + System.currentTimeMillis();
            req.setAttribute("orderId", orderId);

            // Redirect to order success page
            req.getRequestDispatcher("/orderSuccess.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error processing order");
            req.getRequestDispatcher("/cart").forward(req, res);
        }
    }
}
