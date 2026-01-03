package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.*;

public class PaymentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        Order order = (Order) req.getSession().getAttribute("order");
        String method = req.getParameter("method");

        Payment payment;

        if ("Online".equalsIgnoreCase(method)) {
            OnlineBanking ob = new OnlineBanking();
            ob.setAmount(order.calcTotal());
            ob.setPaymentMethod("Online");
            ob.setStatus("Pending");
            payment = ob;
        } else {
            Cash cash = new Cash();
            cash.setAmount(order.calcTotal());
            cash.setPaymentMethod("Cash");
            cash.setStatus("Pending");
            payment = cash;
        }

        // Process payment
        payment.processPayment();

        // Update order status
        order.setStatus(payment.getStatus());

        // Redirect to tracking
        res.sendRedirect("tracking");
    }
}
