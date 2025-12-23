package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class TrackingServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setAttribute("status", "Order Shipped 🚚");
        req.getRequestDispatcher("tracking.jsp").forward(req, res);
    }
}
