package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.model.Patient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/patients")
public class ApiPatientServlet extends HttpServlet {
    private final PatientDAO patientDAO = new PatientDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String query = request.getParameter("query");
        List<Patient> patients;
        if (query != null && !query.trim().isEmpty()) {
            patients = patientDAO.searchPatients(query.trim());
        } else {
            patients = patientDAO.getAllPatients();
        }

        PrintWriter out = response.getWriter();
        out.print(gson.toJson(patients));
        out.flush();
    }
}
