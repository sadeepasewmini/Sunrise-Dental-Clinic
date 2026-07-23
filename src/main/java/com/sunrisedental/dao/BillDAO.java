package com.sunrisedental.dao;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.model.Bill;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BillDAO {

    /**
     * Generates a bill using the MySQL Stored Procedure GenerateBillForAppointment.
     * @param appointmentNumber unique appointment number
     * @param discount amount of discount
     * @return the generated bill ID
     * @throws SQLException if a database error or validation error occurs
     */
    public int generateBill(String appointmentNumber, double discount) throws SQLException {
        String sql = "{call GenerateBillForAppointment(?, ?, ?)}";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             CallableStatement cstmt = conn.prepareCall(sql)) {
             
            cstmt.setString(1, appointmentNumber);
            cstmt.setDouble(2, discount);
            cstmt.registerOutParameter(3, Types.INTEGER);
            
            cstmt.execute();
            return cstmt.getInt(3);
        }
    }

    public Bill getBillByAppointmentNumber(String apptNum) {
        String sql = "SELECT b.*, a.patient_name, d.name AS dentist_name, t.name AS treatment_name " +
                     "FROM bills b " +
                     "JOIN appointments a ON b.appointment_number = a.appointment_number " +
                     "JOIN dentists d ON a.dentist_id = d.id " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "WHERE b.appointment_number = ?";
                     
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, apptNum);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Bill b = new Bill();
                    b.setId(rs.getInt("id"));
                    b.setAppointmentNumber(rs.getString("appointment_number"));
                    b.setConsultationFee(rs.getDouble("consultation_fee"));
                    b.setTreatmentCost(rs.getDouble("treatment_cost"));
                    b.setDiscountAmount(rs.getDouble("discount_amount"));
                    b.setTotalCost(rs.getDouble("total_cost"));
                    b.setNetCost(rs.getDouble("net_cost"));
                    b.setBillingDate(rs.getDate("billing_date"));
                    b.setStatus(rs.getString("status"));
                    b.setCreatedAt(rs.getTimestamp("created_at"));
                    b.setPatientName(rs.getString("patient_name"));
                    b.setDentistName(rs.getString("dentist_name"));
                    b.setTreatmentName(rs.getString("treatment_name"));
                    return b;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching bill by appointment: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean markAsPaid(String apptNum) {
        String sql = "UPDATE bills SET status = 'Paid' WHERE appointment_number = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, apptNum);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error marking bill as paid: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<Bill> getAllBills() {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, a.patient_name, d.name AS dentist_name, t.name AS treatment_name " +
                     "FROM bills b " +
                     "JOIN appointments a ON b.appointment_number = a.appointment_number " +
                     "JOIN dentists d ON a.dentist_id = d.id " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "ORDER BY b.billing_date DESC";
                     
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Bill b = new Bill();
                b.setId(rs.getInt("id"));
                b.setAppointmentNumber(rs.getString("appointment_number"));
                b.setConsultationFee(rs.getDouble("consultation_fee"));
                b.setTreatmentCost(rs.getDouble("treatment_cost"));
                b.setDiscountAmount(rs.getDouble("discount_amount"));
                b.setTotalCost(rs.getDouble("total_cost"));
                b.setNetCost(rs.getDouble("net_cost"));
                b.setBillingDate(rs.getDate("billing_date"));
                b.setStatus(rs.getString("status"));
                b.setCreatedAt(rs.getTimestamp("created_at"));
                b.setPatientName(rs.getString("patient_name"));
                b.setDentistName(rs.getString("dentist_name"));
                b.setTreatmentName(rs.getString("treatment_name"));
                list.add(b);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all bills: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // --- Analytics Methods for Reports ---

    public Map<String, Double> getRevenueReportByDentist() {
        Map<String, Double> data = new HashMap<>();
        String sql = "SELECT d.name, SUM(b.net_cost) as revenue " +
                     "FROM bills b " +
                     "JOIN appointments a ON b.appointment_number = a.appointment_number " +
                     "JOIN dentists d ON a.dentist_id = d.id " +
                     "WHERE b.status = 'Paid' " +
                     "GROUP BY d.name";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                data.put(rs.getString("name"), rs.getDouble("revenue"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return data;
    }

    public double getTotalPaidRevenue() {
        String sql = "SELECT SUM(net_cost) FROM bills WHERE status = 'Paid'";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}
