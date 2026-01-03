package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Request logging filter for monitoring user activities
 */
@WebFilter("/*")
public class LoggingFilter implements Filter {

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    public void init(FilterConfig config) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpReq = (HttpServletRequest) request;
            HttpSession session = httpReq.getSession(false);

            String username = (session != null && session.getAttribute("user") != null)
                    ? ((model.User) session.getAttribute("user")).getUsername()
                    : "Guest";

            String method = httpReq.getMethod();
            String uri = httpReq.getRequestURI();
            String timestamp = LocalDateTime.now().format(formatter);

            // Log the request
            System.out.println("[" + timestamp + "] " + method + " " + uri + " - User: " + username);
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
