package com.sunrisedental.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sunrisedental.dao.AuditDAO;
import com.sunrisedental.dao.UserDAO;
import com.sunrisedental.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/users", "/api/users"})
public class UserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        List<User> users = userDAO.getAllUsers();

        if ("/api/users".equals(path) || "application/json".equals(request.getHeader("Accept"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(users));
            return;
        }

        request.setAttribute("users", users);
        request.setAttribute("activeMenu", "users");
        request.getRequestDispatcher("/WEB-INF/views/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String contentType = request.getContentType();

        if ("/api/users".equals(path) || (contentType != null && contentType.contains("application/json"))) {
            handleJsonCreateUser(request, response);
            return;
        }

        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            handleFormCreateUser(request, response);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleFormDeleteUser(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/users");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Map<String, Object> respMap = new HashMap<>();

        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User toDelete = userDAO.getAllUsers().stream().filter(u -> u.getId() == userId).findFirst().orElse(null);

            if (toDelete != null && "admin".equalsIgnoreCase(toDelete.getUsername())) {
                respMap.put("success", false);
                respMap.put("message", "Cannot delete primary System Administrator account.");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            } else {
                boolean ok = userDAO.deleteUser(userId);
                if (ok) {
                    HttpSession session = request.getSession(false);
                    User actor = session != null ? (User) session.getAttribute("currentUser") : null;
                    String actorName = actor != null ? actor.getUsername() : "System";
                    auditDAO.logAction(actorName, "USER_DELETED", "Deleted user ID: " + userId + " (" + (toDelete != null ? toDelete.getUsername() : "unknown") + ")");

                    respMap.put("success", true);
                    respMap.put("message", "User deleted successfully.");
                } else {
                    respMap.put("success", false);
                    respMap.put("message", "Failed to delete user.");
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                }
            }
        } catch (Exception e) {
            respMap.put("success", false);
            respMap.put("message", "Invalid user ID: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }

        response.getWriter().write(gson.toJson(respMap));
    }

    private void handleJsonCreateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Map<String, Object> respMap = new HashMap<>();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        JsonObject json = gson.fromJson(sb.toString(), JsonObject.class);
        if (json == null) {
            respMap.put("success", false);
            respMap.put("message", "Invalid JSON payload");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(respMap));
            return;
        }

        String username = json.has("username") && !json.get("username").isJsonNull() ? json.get("username").getAsString().trim() : "";
        String password = json.has("password") && !json.get("password").isJsonNull() ? json.get("password").getAsString().trim() : "";
        String fullName = json.has("fullName") && !json.get("fullName").isJsonNull() ? json.get("fullName").getAsString().trim() : username;
        String role = json.has("role") && !json.get("role").isJsonNull() ? json.get("role").getAsString().trim() : "Staff";
        String rawEmail = json.has("email") && !json.get("email").isJsonNull() ? json.get("email").getAsString().trim() : "";
        String email = !rawEmail.isEmpty() ? rawEmail : (username.toLowerCase() + "@sunrisedental.lk");

        if (username.isEmpty() || password.isEmpty()) {
            respMap.put("success", false);
            respMap.put("message", "Username and Password are required.");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(respMap));
            return;
        }

        User user = new User();
        user.setUsername(username);
        user.setFullName(fullName.isEmpty() ? username : fullName);
        user.setRole(role);
        user.setEmail(email);

        boolean created = userDAO.createUser(user, password);
        if (created) {
            HttpSession session = request.getSession(false);
            User actor = session != null ? (User) session.getAttribute("currentUser") : null;
            String actorName = actor != null ? actor.getUsername() : "System";
            auditDAO.logAction(actorName, "USER_CREATED", "Created user account '" + username + "' (" + role + ") with email: " + email);

            respMap.put("success", true);
            respMap.put("message", "User " + username + " created successfully!");
        } else {
            respMap.put("success", false);
            respMap.put("message", "Failed to create user. Username may already exist.");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }

        response.getWriter().write(gson.toJson(respMap));
    }

    private void handleFormCreateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");
        String rawEmail = request.getParameter("email");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Username and Password are required.");
            response.sendRedirect(request.getContextPath() + "/users");
            return;
        }

        String email = (rawEmail != null && !rawEmail.trim().isEmpty()) ? rawEmail.trim() : (username.trim().toLowerCase() + "@sunrisedental.lk");

        User user = new User();
        user.setUsername(username.trim());
        user.setFullName(fullName != null ? fullName.trim() : username.trim());
        user.setRole(role != null ? role.trim() : "Staff");
        user.setEmail(email);

        boolean created = userDAO.createUser(user, password.trim());
        if (created) {
            request.getSession().setAttribute("successMessage", "User " + username + " created successfully!");
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to create user. Username may already exist.");
        }
        response.sendRedirect(request.getContextPath() + "/users");
    }

    private void handleFormDeleteUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User toDelete = userDAO.getAllUsers().stream().filter(u -> u.getId() == userId).findFirst().orElse(null);

            if (toDelete != null && "admin".equalsIgnoreCase(toDelete.getUsername())) {
                request.getSession().setAttribute("errorMessage", "Cannot delete default System Administrator account.");
            } else {
                boolean ok = userDAO.deleteUser(userId);
                if (ok) {
                    request.getSession().setAttribute("successMessage", "User deleted successfully.");
                } else {
                    request.getSession().setAttribute("errorMessage", "Failed to delete user.");
                }
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Invalid user ID: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/users");
    }
}
