package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

@WebServlet(urlPatterns = {
    "/api/reports/summary",
    "/api/reports/dentist-revenue",
    "/api/reports/dentist-appointments",
    "/api/reports/treatment-popularity"
})
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final BillDAO billDAO = new BillDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        String path = request.getServletPath();

        if ("/api/reports/summary".equals(path)) {
            double totalRevenue = billDAO.getTotalPaidRevenue();
            int totalAppts = appointmentDAO.getAllAppointments().size();
            int totalBills = billDAO.getAllBills().size();
            
            JsonObject summary = new JsonObject();
            summary.addProperty("totalRevenue", totalRevenue);
            summary.addProperty("totalAppointments", totalAppts);
            summary.addProperty("totalInvoices", totalBills);
            
            out.print(gson.toJson(summary));
            
        } else if ("/api/reports/dentist-revenue".equals(path)) {
            Map<String, Double> dentistRevenue = billDAO.getRevenueReportByDentist();
            out.print(gson.toJson(dentistRevenue));
            
        } else if ("/api/reports/dentist-appointments".equals(path)) {
            Map<String, Integer> dentistAppts = appointmentDAO.getAppointmentsCountByDentist();
            out.print(gson.toJson(dentistAppts));
            
        } else if ("/api/reports/treatment-popularity".equals(path)) {
            Map<String, Integer> treatmentPop = appointmentDAO.getAppointmentsCountByTreatment();
            out.print(gson.toJson(treatmentPop));
        }

        out.flush();
    }
}
