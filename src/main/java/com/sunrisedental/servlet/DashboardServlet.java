package com.sunrisedental.servlet;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final BillDAO billDAO = new BillDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Appointment> allAppointments = appointmentDAO.getAllAppointments();
        double totalRevenue = billDAO.getTotalPaidRevenue();
        Map<String, Double> dentistRevenue = billDAO.getRevenueReportByDentist();

        long todayCount = allAppointments.size();
        long pendingCount = allAppointments.stream().filter(a -> "Pending".equalsIgnoreCase(a.getStatus())).count();
        long totalPatients = allAppointments.stream().map(Appointment::getPatientName).distinct().count();

        request.setAttribute("totalAppointments", allAppointments.size());
        request.setAttribute("todayAppointments", todayCount);
        request.setAttribute("pendingAppointments", pendingCount);
        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("dentistRevenue", dentistRevenue);
        request.setAttribute("recentAppointments", allAppointments);
        request.setAttribute("activeMenu", "dashboard");

        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}
