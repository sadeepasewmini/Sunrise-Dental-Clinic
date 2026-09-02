package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sunrisedental.dao.UserDAO;
import com.sunrisedental.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(urlPatterns = {"/api/auth/login", "/api/auth/logout", "/api/auth/status"})
public class AuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();

        if ("/api/auth/login".equals(path)) {
            // Parse credentials from request parameters or JSON
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            // If parameters are empty, try parsing from request body
            if (username == null || password == null) {
                try {
                    JsonObject body = gson.fromJson(request.getReader(), JsonObject.class);
                    if (body != null) {
                        username = body.has("username") ? body.get("username").getAsString() : null;
                        password = body.has("password") ? body.get("password").getAsString() : null;
                    }
                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Invalid request body format");
                    out.print(gson.toJson(jsonResponse));
                    return;
                }
            }

            if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Username and password are required");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            User user = userDAO.authenticate(username, password);
            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Login successful");
                jsonResponse.add("user", gson.toJsonTree(user));
            } else {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Invalid username or password");
            }
            out.print(gson.toJson(jsonResponse));
            
        } else if ("/api/auth/logout".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Logout successful");
            out.print(gson.toJson(jsonResponse));
        }
        out.flush();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();

        if ("/api/auth/status".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                jsonResponse.addProperty("authenticated", true);
                jsonResponse.add("user", gson.toJsonTree(user));
            } else {
                jsonResponse.addProperty("authenticated", false);
            }
            out.print(gson.toJson(jsonResponse));
        }
        out.flush();
    }
}
