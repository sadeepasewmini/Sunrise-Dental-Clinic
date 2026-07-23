package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sunrisedental.dao.NotificationDAO;
import com.sunrisedental.model.Notification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(urlPatterns = {"/api/notifications", "/api/notifications/send-pending"})
public class NotificationServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        List<Notification> list = notificationDAO.getAllNotifications();
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(list));
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();

        List<Notification> pending = notificationDAO.getPendingNotifications();
        int sentCount = 0;
        
        for (Notification n : pending) {
            // In a real application, you would call SMS or Email API here.
            // We simulate delivery by updating the status to "Sent".
            boolean success = notificationDAO.updateStatus(n.getId(), "Sent");
            if (success) {
                sentCount++;
            }
        }

        jsonResponse.addProperty("success", true);
        jsonResponse.addProperty("sentCount", sentCount);
        jsonResponse.addProperty("message", "Successfully sent " + sentCount + " pending notifications (Simulated)");
        
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
}
