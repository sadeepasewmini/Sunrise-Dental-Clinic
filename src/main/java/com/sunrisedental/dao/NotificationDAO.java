package com.sunrisedental.dao;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.model.Notification;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean createNotification(Notification notification) {
        String sql = "INSERT INTO notifications (appointment_number, recipient_contact, message_type, message, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, notification.getAppointmentNumber());
            pstmt.setString(2, notification.getRecipientContact());
            pstmt.setString(3, notification.getMessageType());
            pstmt.setString(4, notification.getMessage());
            pstmt.setString(5, notification.getStatus() != null ? notification.getStatus() : "Pending");
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error creating notification: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> getPendingNotifications() {
        return getNotificationsByStatus("Pending");
    }

    public List<Notification> getNotificationsByStatus(String status) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE LOWER(status) = LOWER(?) ORDER BY sent_at DESC";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification(
                        rs.getInt("id"),
                        rs.getString("appointment_number"),
                        rs.getString("recipient_contact"),
                        rs.getString("message_type"),
                        rs.getString("message"),
                        rs.getString("status"),
                        rs.getTimestamp("sent_at")
                    );
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching notifications by status: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE notifications SET status = ?, sent_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating notification status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteNotification(int id) {
        String sql = "DELETE FROM notifications WHERE id = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting notification: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> getAllNotifications() {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications ORDER BY sent_at DESC";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Notification n = new Notification(
                    rs.getInt("id"),
                    rs.getString("appointment_number"),
                    rs.getString("recipient_contact"),
                    rs.getString("message_type"),
                    rs.getString("message"),
                    rs.getString("status"),
                    rs.getTimestamp("sent_at")
                );
                list.add(n);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all notifications: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}
