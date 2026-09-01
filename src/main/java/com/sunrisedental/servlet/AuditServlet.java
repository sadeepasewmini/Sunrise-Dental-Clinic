package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.sunrisedental.dao.AuditDAO;
import com.sunrisedental.model.AuditLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/audit-logs")
public class AuditServlet extends HttpServlet {
    private final AuditDAO auditDAO = new AuditDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        List<AuditLog> logs = auditDAO.getAllAuditLogs();
        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(logs));
            out.flush();
        }
    }
}
