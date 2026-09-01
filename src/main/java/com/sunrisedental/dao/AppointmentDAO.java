package com.sunrisedental.dao;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.model.Appointment;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AppointmentDAO {

    /**
     * Creates an appointment. Generates a unique sequential appointment number inside a transaction.
     * Throws SQLException if double booking or database error occurs.
     */
    public String createAppointment(Appointment appt) throws SQLException {
        String sql = "INSERT INTO appointments (appointment_number, patient_name, patient_address, patient_contact, dentist_id, treatment_id, tooth_number, appointment_date, appointment_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getInstance().getConnection()) {
            conn.setAutoCommit(false);
            try {
                String apptNum = generateNextAppointmentNumber(conn);
                appt.setAppointmentNumber(apptNum);
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, apptNum);
                    pstmt.setString(2, appt.getPatientName());
                    pstmt.setString(3, appt.getPatientAddress());
                    pstmt.setString(4, appt.getPatientContact());
                    pstmt.setInt(5, appt.getDentistId());
                    pstmt.setInt(6, appt.getTreatmentId());
                    pstmt.setString(7, appt.getToothNumber() != null ? appt.getToothNumber() : "General");
                    pstmt.setDate(8, appt.getAppointmentDate());
                    pstmt.setTime(9, appt.getAppointmentTime());
                    pstmt.setString(10, "Pending");
                    
                    pstmt.executeUpdate();
                }
                conn.commit();
                return apptNum;
            } catch (SQLException e) {
                conn.rollback();
                throw e; // Reraise exception (trigger errors like double-booking will be propagated here)
            }
        }
    }

    private String generateNextAppointmentNumber(Connection conn) throws SQLException {
        String sql = "SELECT MAX(id) FROM appointments";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                int maxId = rs.getInt(1);
                return String.format("APT-%04d", maxId + 1);
            }
        }
        return "APT-0001";
    }

    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, d.name AS dentist_name, t.name AS treatment_name, p.allergies, p.medical_conditions " +
                     "FROM appointments a " +
                     "JOIN dentists d ON a.dentist_id = d.id " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "LEFT JOIN patients p ON a.patient_contact = p.contact_number " +
                     "ORDER BY a.appointment_date DESC, a.appointment_time DESC";
                     
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Appointment a = new Appointment();
                a.setId(rs.getInt("id"));
                a.setAppointmentNumber(rs.getString("appointment_number"));
                a.setPatientName(rs.getString("patient_name"));
                a.setPatientAddress(rs.getString("patient_address"));
                a.setPatientContact(rs.getString("patient_contact"));
                a.setDentistId(rs.getInt("dentist_id"));
                a.setTreatmentId(rs.getInt("treatment_id"));
                a.setToothNumber(rs.getString("tooth_number"));
                a.setAppointmentDate(rs.getDate("appointment_date"));
                a.setAppointmentTime(rs.getTime("appointment_time"));
                a.setStatus(rs.getString("status"));
                a.setCreatedAt(rs.getTimestamp("created_at"));
                a.setDentistName(rs.getString("dentist_name"));
                a.setTreatmentName(rs.getString("treatment_name"));
                a.setAllergies(rs.getString("allergies"));
                a.setMedicalConditions(rs.getString("medical_conditions"));
                list.add(a);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all appointments: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public Appointment getAppointmentByNumber(String apptNum) {
        String sql = "SELECT a.*, d.name AS dentist_name, t.name AS treatment_name, p.allergies, p.medical_conditions " +
                     "FROM appointments a " +
                     "JOIN dentists d ON a.dentist_id = d.id " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "LEFT JOIN patients p ON a.patient_contact = p.contact_number " +
                     "WHERE a.appointment_number = ?";
                     
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, apptNum);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Appointment a = new Appointment();
                    a.setId(rs.getInt("id"));
                    a.setAppointmentNumber(rs.getString("appointment_number"));
                    a.setPatientName(rs.getString("patient_name"));
                    a.setPatientAddress(rs.getString("patient_address"));
                    a.setPatientContact(rs.getString("patient_contact"));
                    a.setDentistId(rs.getInt("dentist_id"));
                    a.setTreatmentId(rs.getInt("treatment_id"));
                    a.setToothNumber(rs.getString("tooth_number"));
                    a.setAppointmentDate(rs.getDate("appointment_date"));
                    a.setAppointmentTime(rs.getTime("appointment_time"));
                    a.setStatus(rs.getString("status"));
                    a.setCreatedAt(rs.getTimestamp("created_at"));
                    a.setDentistName(rs.getString("dentist_name"));
                    a.setTreatmentName(rs.getString("treatment_name"));
                    a.setAllergies(rs.getString("allergies"));
                    a.setMedicalConditions(rs.getString("medical_conditions"));
                    return a;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error searching appointment by number: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Search appointments by appointment number, patient name, or contact number (case-insensitive substring match).
     * @param query Search query text
     * @return List of matching appointments
     */
    public List<Appointment> searchAppointments(String query) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, d.name AS dentist_name, t.name AS treatment_name, p.allergies, p.medical_conditions " +
                     "FROM appointments a " +
                     "JOIN dentists d ON a.dentist_id = d.id " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "LEFT JOIN patients p ON a.patient_contact = p.contact_number " +
                     "WHERE LOWER(a.appointment_number) LIKE ? " +
                     "OR LOWER(a.patient_name) LIKE ? " +
                     "OR a.patient_contact LIKE ? " +
                     "ORDER BY a.appointment_date DESC, a.appointment_time DESC";
                     
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String pattern = "%" + query.toLowerCase().trim() + "%";
            pstmt.setString(1, pattern);
            pstmt.setString(2, pattern);
            pstmt.setString(3, pattern);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Appointment a = new Appointment();
                    a.setId(rs.getInt("id"));
                    a.setAppointmentNumber(rs.getString("appointment_number"));
                    a.setPatientName(rs.getString("patient_name"));
                    a.setPatientAddress(rs.getString("patient_address"));
                    a.setPatientContact(rs.getString("patient_contact"));
                    a.setDentistId(rs.getInt("dentist_id"));
                    a.setTreatmentId(rs.getInt("treatment_id"));
                    a.setToothNumber(rs.getString("tooth_number"));
                    a.setAppointmentDate(rs.getDate("appointment_date"));
                    a.setAppointmentTime(rs.getTime("appointment_time"));
                    a.setStatus(rs.getString("status"));
                    a.setCreatedAt(rs.getTimestamp("created_at"));
                    a.setDentistName(rs.getString("dentist_name"));
                    a.setTreatmentName(rs.getString("treatment_name"));
                    a.setAllergies(rs.getString("allergies"));
                    a.setMedicalConditions(rs.getString("medical_conditions"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error searching appointments: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(String apptNum, String status) {
        String sql = "UPDATE appointments SET status = ? WHERE appointment_number = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setString(2, apptNum);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating appointment status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // --- Analytics Methods for Reports ---

    public Map<String, Integer> getAppointmentsCountByDentist() {
        Map<String, Integer> data = new HashMap<>();
        String sql = "SELECT d.name, COUNT(a.id) as count " +
                     "FROM appointments a " +
                     "JOIN dentists d ON a.dentist_id = d.id " +
                     "GROUP BY d.name";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                data.put(rs.getString("name"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return data;
    }

    public Map<String, Integer> getAppointmentsCountByTreatment() {
        Map<String, Integer> data = new HashMap<>();
        String sql = "SELECT t.name, COUNT(a.id) as count " +
                     "FROM appointments a " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "GROUP BY t.name";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                data.put(rs.getString("name"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return data;
    }
}
