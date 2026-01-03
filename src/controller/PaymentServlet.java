package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
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

        // Update order status
        order.setStatus(payment.getStatus());

        // Clear cart after successful payment
        session.removeAttribute("cart");

        // Redirect to tracking
        res.sendRedirect(req.getContextPath() + "/tracking");
    }
}
