package com.sunrisedental.dao;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.model.Treatment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TreatmentDAO {

    public List<Treatment> getAllTreatments() {
        List<Treatment> treatments = new ArrayList<>();
        String sql = "SELECT * FROM treatments ORDER BY name ASC";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Treatment treatment = new Treatment(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getDouble("cost")
                );
                treatments.add(treatment);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching treatments: " + e.getMessage());
            e.printStackTrace();
        }
        return treatments;
    }

    public Treatment getTreatmentById(int id) {
        String sql = "SELECT * FROM treatments WHERE id = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new Treatment(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getDouble("cost")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching treatment by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
