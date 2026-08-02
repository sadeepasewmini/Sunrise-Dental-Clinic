package com.sunrisedental.servlet;

import com.sunrisedental.dao.NotificationDAO;
import com.sunrisedental.model.Notification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Notification> logs = notificationDAO.getAllNotifications();
        request.setAttribute("logs", logs);
        request.setAttribute("activeMenu", "notifications");
        request.getRequestDispatcher("/WEB-INF/views/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("dispatch".equalsIgnoreCase(action)) {
            List<Notification> pending = notificationDAO.getPendingNotifications();
            for (Notification n : pending) {
                notificationDAO.updateStatus(n.getId(), "Sent");
            }
            request.getSession().setAttribute("successMessage", "Automated patient reminder notifications (" + pending.size() + ") dispatched successfully!");
        }
        response.sendRedirect(request.getContextPath() + "/notifications");
    }
}
