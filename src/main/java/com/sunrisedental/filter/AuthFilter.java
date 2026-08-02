package com.sunrisedental.filter;

import com.sunrisedental.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String path = request.getRequestURI().substring(request.getContextPath().length());

        // Allow static resources (css, js, images) and login page/servlet
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/") ||
            path.equals("/login") || path.equals("/login.jsp") || path.equals("/index.jsp")) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Restrict /users endpoint to Admin role only
        if (path.startsWith("/users") && !"Admin".equalsIgnoreCase(currentUser.getRole())) {
            request.setAttribute("errorMessage", "Access Denied: Admin privileges required.");
            request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
            return;
        }

        chain.doFilter(req, res);
    }
}
