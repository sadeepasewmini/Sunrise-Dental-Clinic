package com.sunrisedental.servlet;

import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.model.Patient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/patients")
public class PatientServlet extends HttpServlet {
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        patientDAO = new PatientDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "register":
                request.setAttribute("activeMenu", "register_patient");
                request.getRequestDispatcher("/WEB-INF/views/register-patient.jsp").forward(request, response);
                break;
            case "list":
            default:
                List<Patient> patients = patientDAO.getAllPatients();
                request.setAttribute("patients", patients);
                request.setAttribute("activeMenu", "patients");
                request.getRequestDispatcher("/WEB-INF/views/patients.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String contactNumber = request.getParameter("contactNumber");
            String email = request.getParameter("email");
            String allergies = request.getParameter("allergies");
            String medicalConditions = request.getParameter("medicalConditions");

            Patient patient = new Patient(0, name, address, contactNumber, email, 
                allergies != null && !allergies.trim().isEmpty() ? allergies.trim() : "None", 
                medicalConditions != null && !medicalConditions.trim().isEmpty() ? medicalConditions.trim() : "None", 
                null);

            if (patientDAO.addPatient(patient)) {
                request.getSession().setAttribute("successMessage", "Patient registered successfully.");
                response.sendRedirect(request.getContextPath() + "/patients?action=list");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to register patient. Please try again.");
                response.sendRedirect(request.getContextPath() + "/patients?action=register");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
