package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.model.Dentist;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/dentists")
public class DentistServlet extends HttpServlet {
    private final DentistDAO dentistDAO = new DentistDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        List<Dentist> dentists = dentistDAO.getAllDentists();
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(dentists));
        out.flush();
    }
}
