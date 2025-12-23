package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.*;

public class OrderServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        try {
            // Parse price from request
            double price = Double.parseDouble(req.getParameter("price"));

            // Create OrderDetails (quantity=1, product=null)
            OrderDetails od = new OrderDetails(1, price, null);

            // Create a list of order details
            List<OrderDetails> detailsList = new ArrayList<>();
            detailsList.add(od);

            // Create Order with list of OrderDetails
            Order order = new Order();
            order.setOrderDetails(detailsList);
            order.setStatus("Pending");

            // Store in session
            req.getSession().setAttribute("order", order);

            // Redirect to payment page
            res.sendRedirect("payment.jsp");

        } catch (NumberFormatException e) {
            // Handle invalid input
            req.setAttribute("error", "Invalid price input");
            req.getRequestDispatcher("products.jsp").forward(req, res);
        }
    }
}
