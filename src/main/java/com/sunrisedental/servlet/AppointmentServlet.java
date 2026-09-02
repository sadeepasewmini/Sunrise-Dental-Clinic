package com.sunrisedental.servlet;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Dentist;
import com.sunrisedental.model.Treatment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.List;

@WebServlet("/appointments")
public class AppointmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DentistDAO dentistDAO = new DentistDAO();
    private final TreatmentDAO treatmentDAO = new TreatmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "register";

        switch (action) {
            case "search":
                showSearchPage(request, response);
                break;
            case "register":
            default:
                showRegisterPage(request, response);
                break;
        }
    }

    private void showRegisterPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Dentist> dentists = dentistDAO.getAllDentists();
        List<Treatment> treatments = treatmentDAO.getAllTreatments();

        request.setAttribute("dentists", dentists);
        request.setAttribute("treatments", treatments);
        request.setAttribute("activeMenu", "register");

        request.getRequestDispatcher("/WEB-INF/views/register-appointment.jsp").forward(request, response);
    }

    private void showSearchPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String query = request.getParameter("query");
        if (query != null && !query.trim().isEmpty()) {
            List<Appointment> searchResults = appointmentDAO.searchAppointments(query.trim());
            request.setAttribute("searchResults", searchResults);
            request.setAttribute("query", query.trim());
        }
        request.setAttribute("activeMenu", "search");
        request.getRequestDispatcher("/WEB-INF/views/search-appointment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equalsIgnoreCase(action)) {
            handleCreateAppointment(request, response);
        } else if ("updateStatus".equalsIgnoreCase(action)) {
            handleUpdateStatus(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/appointments?action=register");
        }
    }

    private void handleCreateAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String name = request.getParameter("patientName");
            String address = request.getParameter("patientAddress");
            String contact = request.getParameter("patientContact");
            int dentistId = Integer.parseInt(request.getParameter("dentistId"));
            int treatmentId = Integer.parseInt(request.getParameter("treatmentId"));
            String dateStr = request.getParameter("appointmentDate");
            String timeStr = request.getParameter("appointmentTime");
            String toothNumber = request.getParameter("toothNumber");
            String allergies = request.getParameter("allergies");
            String medicalConditions = request.getParameter("medicalConditions");

            if (timeStr != null && timeStr.length() == 5) {
                timeStr += ":00";
            }

            // --- Auto-Register Patient Logic ---
            com.sunrisedental.dao.PatientDAO patientDAO = new com.sunrisedental.dao.PatientDAO();
            com.sunrisedental.model.Patient existingPatient = patientDAO.getPatientByContact(contact);
            if (existingPatient == null) {
                com.sunrisedental.model.Patient newPatient = new com.sunrisedental.model.Patient(0, name, address, contact, "", 
                    allergies != null && !allergies.trim().isEmpty() ? allergies.trim() : "None", 
                    medicalConditions != null && !medicalConditions.trim().isEmpty() ? medicalConditions.trim() : "None", 
                    null);
                patientDAO.addPatient(newPatient);
            }
            // ------------------------------------

            Appointment appt = new Appointment();
            appt.setPatientName(name);
            appt.setPatientAddress(address);
            appt.setPatientContact(contact);
            appt.setDentistId(dentistId);
            appt.setTreatmentId(treatmentId);
            appt.setToothNumber(toothNumber != null && !toothNumber.trim().isEmpty() ? toothNumber.trim() : "General");
            appt.setAppointmentDate(Date.valueOf(dateStr));
            appt.setAppointmentTime(Time.valueOf(timeStr));
            appt.setStatus("Pending");

            String apptNum = appointmentDAO.createAppointment(appt);
            if (apptNum != null) {
                request.getSession().setAttribute("successMessage", "Appointment registered successfully! Number: " + apptNum);
                response.sendRedirect(request.getContextPath() + "/appointments?action=search&query=" + apptNum);
            } else {
                request.setAttribute("errorMessage", "Failed to register appointment.");
                showRegisterPage(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid input or schedule conflict: " + e.getMessage());
            showRegisterPage(request, response);
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apptNumber = request.getParameter("number");
        String status = request.getParameter("status");
        boolean ok = appointmentDAO.updateStatus(apptNumber, status);
        if (ok) {
            request.getSession().setAttribute("successMessage", "Appointment status updated to " + status);
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to update appointment status.");
        }
        String redirectUrl = request.getParameter("redirectUrl");
        if (redirectUrl != null && !redirectUrl.isEmpty()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }
}
