package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Bill;
import com.sunrisedental.service.BillingStrategy;
import com.sunrisedental.service.BillingStrategyFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/api/bills", "/api/bills/calculate", "/api/bills/generate", "/api/bills/pay"})
public class BillServlet extends HttpServlet {
    private final BillDAO billDAO = new BillDAO();
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
            Bill bill = billDAO.getBillByAppointmentNumber(number);
            if (bill != null) {
                out.print(gson.toJson(bill));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject err = new JsonObject();
                err.addProperty("success", false);
                err.addProperty("message", "Bill not found for appointment: " + number);
                out.print(gson.toJson(err));
            }
        } else {
            List<Bill> list = billDAO.getAllBills();
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
        String path = request.getServletPath();

        try {
            JsonObject body = gson.fromJson(request.getReader(), JsonObject.class);
            if (body == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Request body is required");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            String apptNum = body.has("appointmentNumber") ? body.get("appointmentNumber").getAsString() : null;
            if (apptNum == null || apptNum.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Appointment number is required");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            // Fetch appointment details to verify and get fees
            Appointment appt = appointmentDAO.getAppointmentByNumber(apptNum);
            if (appt == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Appointment not found: " + apptNum);
                out.print(gson.toJson(jsonResponse));
                return;
            }

            // Fetch dentist and treatment details
            double consultationFee = 0.0;
            double treatmentCost = 0.0;
            
            // Get dentist fee (we can fetch this using DB connection or directly since it is in our models)
            // Let's get these via DAO or simple queries. In our system, appt has dentistId and treatmentId.
            // In a simple way, let's load them:
            com.sunrisedental.dao.DentistDAO dentistDAO = new com.sunrisedental.dao.DentistDAO();
            com.sunrisedental.dao.TreatmentDAO treatmentDAO = new com.sunrisedental.dao.TreatmentDAO();
            
            com.sunrisedental.model.Dentist dentist = dentistDAO.getDentistById(appt.getDentistId());
            com.sunrisedental.model.Treatment treatment = treatmentDAO.getTreatmentById(appt.getTreatmentId());
            
            if (dentist != null) consultationFee = dentist.getConsultationFee();
            if (treatment != null) treatmentCost = treatment.getCost();

            double manualDiscount = body.has("manualDiscount") ? body.get("manualDiscount").getAsDouble() : 0.0;
            String strategyType = body.has("billingStrategy") ? body.get("billingStrategy").getAsString() : "STANDARD";

            // Calculate final net cost using Java Strategy Pattern
            BillingStrategy strategy = BillingStrategyFactory.getStrategy(strategyType);
            double netCost = strategy.calculateNetCost(consultationFee, treatmentCost, manualDiscount);
            
            // The difference between standard cost and net cost is the total discount applied
            double totalCost = consultationFee + treatmentCost;
            double calculatedDiscount = totalCost - netCost;

            if ("/api/bills/calculate".equals(path)) {
                // Return calculations without saving
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("appointmentNumber", apptNum);
                jsonResponse.addProperty("patientName", appt.getPatientName());
                jsonResponse.addProperty("dentistName", dentist != null ? dentist.getName() : "");
                jsonResponse.addProperty("treatmentName", treatment != null ? treatment.getName() : "");
                jsonResponse.addProperty("consultationFee", consultationFee);
                jsonResponse.addProperty("treatmentCost", treatmentCost);
                jsonResponse.addProperty("totalCost", totalCost);
                jsonResponse.addProperty("discountAmount", calculatedDiscount);
                jsonResponse.addProperty("netCost", netCost);
                response.setStatus(HttpServletResponse.SC_OK);
                
            } else if ("/api/bills/generate".equals(path)) {
                // Generate the bill using the Stored Procedure in DB.
                // We pass the calculated discount amount to the stored procedure.
                int billId = billDAO.generateBill(apptNum, calculatedDiscount);
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("billId", billId);
                jsonResponse.addProperty("message", "Bill generated successfully! Status updated to Completed.");
                response.setStatus(HttpServletResponse.SC_CREATED);
                
            } else if ("/api/bills/pay".equals(path)) {
                // Mark existing bill as Paid
                boolean ok = billDAO.markAsPaid(apptNum);
                if (ok) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", "Payment recorded successfully! Invoice marked as Paid.");
                    response.setStatus(HttpServletResponse.SC_OK);
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Could not mark bill as paid");
                }
            }
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database Error: " + e.getMessage());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error: " + e.getMessage());
        }

        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
}
