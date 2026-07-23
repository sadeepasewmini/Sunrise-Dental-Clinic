package com.sunrisedental.dao;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.model.Notification;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public List<Notification> getPendingNotifications() {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE status = 'Pending' ORDER BY sent_at ASC";
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
            System.err.println("Error fetching pending notifications: " + e.getMessage());
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
