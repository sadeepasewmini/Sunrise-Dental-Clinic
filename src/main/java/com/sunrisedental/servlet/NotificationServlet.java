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
    private static final long serialVersionUID = 1L;
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String statusFilter = request.getParameter("status");
        List<Notification> logs;

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            logs = notificationDAO.getNotificationsByStatus(statusFilter.trim());
            request.setAttribute("selectedStatus", statusFilter.trim());
        } else {
            logs = notificationDAO.getAllNotifications();
        }

        request.setAttribute("logs", logs);
        request.setAttribute("activeMenu", "notifications");
        request.getRequestDispatcher("/WEB-INF/views/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if ("dispatch".equalsIgnoreCase(action)) {
                handleDispatch(request);
            } else if ("create".equalsIgnoreCase(action)) {
                handleCreateNotification(request);
            } else if ("delete".equalsIgnoreCase(action)) {
                handleDeleteNotification(request);
            } else if ("updateStatus".equalsIgnoreCase(action)) {
                handleUpdateStatus(request);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error processing notification action: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/notifications");
    }

    private void handleDispatch(HttpServletRequest request) {
        List<Notification> pending = notificationDAO.getPendingNotifications();
        if (pending.isEmpty()) {
            request.getSession().setAttribute("infoMessage", "No pending notifications to dispatch at this time.");
            return;
        }

        int count = 0;
        for (Notification n : pending) {
            if (notificationDAO.updateStatus(n.getId(), "Sent")) {
                count++;
            }
        }
        request.getSession().setAttribute("successMessage", "Automated patient reminder notifications (" + count + ") dispatched successfully!");
    }

    private void handleCreateNotification(HttpServletRequest request) {
        String apptNumber = request.getParameter("appointmentNumber");
        String recipientContact = request.getParameter("recipientContact");
        String messageType = request.getParameter("messageType");
        String message = request.getParameter("message");

        if (recipientContact == null || recipientContact.trim().isEmpty() || message == null || message.trim().isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Recipient contact and message body are required.");
            return;
        }

        Notification notification = new Notification();
        notification.setAppointmentNumber(apptNumber != null ? apptNumber.trim() : "");
        notification.setRecipientContact(recipientContact.trim());
        notification.setMessageType(messageType != null && !messageType.trim().isEmpty() ? messageType.trim() : "SMS");
        notification.setMessage(message.trim());
        notification.setStatus("Pending");

        boolean success = notificationDAO.createNotification(notification);
        if (success) {
            request.getSession().setAttribute("successMessage", "New notification queued successfully!");
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to create notification.");
        }
    }

    private void handleDeleteNotification(HttpServletRequest request) {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            int id = Integer.parseInt(idStr.trim());
            boolean success = notificationDAO.deleteNotification(id);
            if (success) {
                request.getSession().setAttribute("successMessage", "Notification log deleted successfully.");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete notification log.");
            }
        }
    }

    private void handleUpdateStatus(HttpServletRequest request) {
        String idStr = request.getParameter("id");
        String status = request.getParameter("status");
        if (idStr != null && status != null) {
            int id = Integer.parseInt(idStr.trim());
            boolean success = notificationDAO.updateStatus(id, status.trim());
            if (success) {
                request.getSession().setAttribute("successMessage", "Notification status updated to " + status + ".");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update status.");
            }
        }
    }
}
