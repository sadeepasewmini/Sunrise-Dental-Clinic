package com.sunrisedental.dao;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.model.Dentist;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DentistDAO {

    public List<Dentist> getAllDentists() {
        List<Dentist> dentists = new ArrayList<>();
        String sql = "SELECT * FROM dentists ORDER BY name ASC";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Dentist dentist = new Dentist(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("specialization"),
                    rs.getString("contact_number"),
                    rs.getDouble("consultation_fee")
                );
                dentists.add(dentist);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all dentists: " + e.getMessage());
            e.printStackTrace();
        }
        return dentists;
    }

    public Dentist getDentistById(int id) {
        String sql = "SELECT * FROM dentists WHERE id = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new Dentist(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("specialization"),
                        rs.getString("contact_number"),
                        rs.getDouble("consultation_fee")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching dentist by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean addDentist(Dentist dentist) {
        String sql = "INSERT INTO dentists (name, specialization, contact_number, consultation_fee) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dentist.getName());
            pstmt.setString(2, dentist.getSpecialization());
            pstmt.setString(3, dentist.getContactNumber());
            pstmt.setDouble(4, dentist.getConsultationFee());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error adding dentist: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateDentist(Dentist dentist) {
        String sql = "UPDATE dentists SET name = ?, specialization = ?, contact_number = ?, consultation_fee = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dentist.getName());
            pstmt.setString(2, dentist.getSpecialization());
            pstmt.setString(3, dentist.getContactNumber());
            pstmt.setDouble(4, dentist.getConsultationFee());
            pstmt.setInt(5, dentist.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating dentist: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteDentist(int id) {
        String sql = "DELETE FROM dentists WHERE id = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting dentist: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
