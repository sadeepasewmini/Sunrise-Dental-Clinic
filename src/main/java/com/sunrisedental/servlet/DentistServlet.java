package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.sunrisedental.dao.AuditDAO;
import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.model.Dentist;
import com.sunrisedental.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(urlPatterns = {"/dentists", "/api/dentists"})
public class DentistServlet extends HttpServlet {
    private final DentistDAO dentistDAO = new DentistDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        List<Dentist> dentists = dentistDAO.getAllDentists();

        if ("/api/dentists".equals(path) || "application/json".equals(request.getHeader("Accept"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(gson.toJson(dentists));
            out.flush();
            return;
        }

        request.setAttribute("dentists", dentists);
        request.setAttribute("activeMenu", "dentists");
        request.getRequestDispatcher("/WEB-INF/views/dentists.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equalsIgnoreCase(action)) {
            handleCreateDentist(request, response);
        } else if ("update".equalsIgnoreCase(action)) {
            handleUpdateDentist(request, response);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDeleteDentist(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/dentists");
        }
    }

    private void handleUpdateDentist(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String specialization = request.getParameter("specialization");
            String contactNumber = request.getParameter("contactNumber");
            double consultationFee = 1000.0;

            try {
                consultationFee = Double.parseDouble(request.getParameter("consultationFee"));
            } catch (Exception ignored) {}

            if (name == null || name.trim().isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Dentist Name is required.");
                response.sendRedirect(request.getContextPath() + "/dentists");
                return;
            }

            Dentist dentist = new Dentist(id, name.trim(), specialization != null ? specialization.trim() : "General Practitioner", contactNumber != null ? contactNumber.trim() : "", consultationFee);
            boolean updated = dentistDAO.updateDentist(dentist);

            if (updated) {
                HttpSession session = request.getSession(false);
                User actor = session != null ? (User) session.getAttribute("currentUser") : null;
                String actorName = actor != null ? actor.getUsername() : "System";
                auditDAO.logAction(actorName, "DENTIST_UPDATED", "Updated dentist ID: " + id + " ('" + name.trim() + "')");

                request.getSession().setAttribute("successMessage", "Dentist '" + name.trim() + "' updated successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update dentist details.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Invalid request parameters: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/dentists");
    }

    private void handleCreateDentist(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("name");
        String specialization = request.getParameter("specialization");
        String contactNumber = request.getParameter("contactNumber");
        double consultationFee = 1000.0;

        try {
            consultationFee = Double.parseDouble(request.getParameter("consultationFee"));
        } catch (Exception ignored) {}

        if (name == null || name.trim().isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Dentist Name is required.");
            response.sendRedirect(request.getContextPath() + "/dentists");
            return;
        }

        Dentist dentist = new Dentist(0, name.trim(), specialization != null ? specialization.trim() : "General Dentist", contactNumber != null ? contactNumber.trim() : "", consultationFee);
        boolean created = dentistDAO.addDentist(dentist);

        if (created) {
            HttpSession session = request.getSession(false);
            User actor = session != null ? (User) session.getAttribute("currentUser") : null;
            String actorName = actor != null ? actor.getUsername() : "System";
            auditDAO.logAction(actorName, "DENTIST_ADDED", "Added dentist '" + name.trim() + "' (" + specialization + ")");

            request.getSession().setAttribute("successMessage", "Dentist '" + name.trim() + "' added successfully!");
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to add dentist.");
        }
        response.sendRedirect(request.getContextPath() + "/dentists");
    }

    private void handleDeleteDentist(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Dentist existing = dentistDAO.getDentistById(id);

            boolean deleted = dentistDAO.deleteDentist(id);
            if (deleted) {
                HttpSession session = request.getSession(false);
                User actor = session != null ? (User) session.getAttribute("currentUser") : null;
                String actorName = actor != null ? actor.getUsername() : "System";
                auditDAO.logAction(actorName, "DENTIST_DELETED", "Deleted dentist ID: " + id + " (" + (existing != null ? existing.getName() : "unknown") + ")");

                request.getSession().setAttribute("successMessage", "Dentist deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete dentist. Dentist may be assigned to existing appointments.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Invalid dentist ID: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/dentists");
    }
}
