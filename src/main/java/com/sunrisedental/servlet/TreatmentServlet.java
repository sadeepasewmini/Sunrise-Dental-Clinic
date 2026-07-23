package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Treatment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/treatments")
public class TreatmentServlet extends HttpServlet {
    private final TreatmentDAO treatmentDAO = new TreatmentDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        List<Treatment> treatments = treatmentDAO.getAllTreatments();
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(treatments));
        out.flush();
    }
}
