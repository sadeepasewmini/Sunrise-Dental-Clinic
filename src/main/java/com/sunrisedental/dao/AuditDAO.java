package com.sunrisedental.dao;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.model.AuditLog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AuditDAO {

    public void logAction(String username, String action, String details) {
        String sql = "INSERT INTO audit_logs (username, action, details) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username != null ? username : "System");
            pstmt.setString(2, action);
            pstmt.setString(3, details);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Failed to insert audit log: " + e.getMessage());
        }
    }

    public List<AuditLog> getAllAuditLogs() {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT id, username, action, details, created_at FROM audit_logs ORDER BY id DESC LIMIT 100";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setId(rs.getInt("id"));
                log.setUsername(rs.getString("username"));
                log.setAction(rs.getString("action"));
                log.setDetails(rs.getString("details"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(log);
            }
        } catch (SQLException e) {
            System.err.println("Failed to fetch audit logs: " + e.getMessage());
        }
        return list;
    }
}
