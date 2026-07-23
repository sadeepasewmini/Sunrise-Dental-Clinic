package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.model.Appointment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.Time;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/appointments")
public class AppointmentServlet extends HttpServlet {
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String number = request.getParameter("number");
        
        if (number != null && !number.trim().isEmpty()) {
            // Search appointment by number
            Appointment appt = appointmentDAO.getAppointmentByNumber(number);
            if (appt != null) {
                out.print(gson.toJson(appt));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject err = new JsonObject();
                err.addProperty("success", false);
                err.addProperty("message", "Appointment not found with number: " + number);
                out.print(gson.toJson(err));
            }
        } else {
            // Return all appointments
            List<Appointment> list = appointmentDAO.getAllAppointments();
            out.print(gson.toJson(list));
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();

        try {
            // Read and parse JSON request body
            JsonObject body = gson.fromJson(request.getReader(), JsonObject.class);
            
            if (body == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Request body is empty");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            // Extract parameters and validate
            String patientName = body.has("patientName") ? body.get("patientName").getAsString() : null;
            String patientAddress = body.has("patientAddress") ? body.get("patientAddress").getAsString() : null;
            String patientContact = body.has("patientContact") ? body.get("patientContact").getAsString() : null;
            int dentistId = body.has("dentistId") ? body.get("dentistId").getAsInt() : 0;
            int treatmentId = body.has("treatmentId") ? body.get("treatmentId").getAsInt() : 0;
            String dateStr = body.has("appointmentDate") ? body.get("appointmentDate").getAsString() : null;
            String timeStr = body.has("appointmentTime") ? body.get("appointmentTime").getAsString() : null;

            // Basic validation
            if (patientName == null || patientName.trim().isEmpty() ||
                patientAddress == null || patientAddress.trim().isEmpty() ||
                patientContact == null || patientContact.trim().isEmpty() ||
                dentistId == 0 || treatmentId == 0 ||
                dateStr == null || dateStr.trim().isEmpty() ||
                timeStr == null || timeStr.trim().isEmpty()) {
                
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "All fields are required and must be valid");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            // Create Appointment bean
            Appointment appt = new Appointment();
            appt.setPatientName(patientName.trim());
            appt.setPatientAddress(patientAddress.trim());
            appt.setPatientContact(patientContact.trim());
            appt.setDentistId(dentistId);
            appt.setTreatmentId(treatmentId);
            
            // Format time if it is HH:MM to HH:MM:00
            if (timeStr.length() == 5) {
                timeStr += ":00";
            }
            
            appt.setAppointmentDate(Date.valueOf(dateStr));
            appt.setAppointmentTime(Time.valueOf(timeStr));

            // Create in database (will execute the double-booking trigger)
            String apptNum = appointmentDAO.createAppointment(appt);
            
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("appointmentNumber", apptNum);
            jsonResponse.addProperty("message", "Appointment registered successfully! Confirmation SMS queued.");
            response.setStatus(HttpServletResponse.SC_CREATED);
            
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Invalid Date or Time format");
        } catch (SQLException e) {
            // Catch double booking trigger exception (SQLSTATE 45000) or other database errors
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            jsonResponse.addProperty("success", false);
            // SQLSTATE 45000 is thrown by trigger, check if it contains the message
            String errorMsg = e.getMessage();
            if (errorMsg.contains("Double booking error")) {
                jsonResponse.addProperty("message", "Validation Error: The dentist is already booked at this date and time.");
            } else {
                jsonResponse.addProperty("message", "Database Error: " + errorMsg);
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Internal Server Error: " + e.getMessage());
        }

        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
}
