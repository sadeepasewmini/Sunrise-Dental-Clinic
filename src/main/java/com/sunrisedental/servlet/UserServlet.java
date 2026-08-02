package com.sunrisedental.servlet;

import com.sunrisedental.dao.UserDAO;
import com.sunrisedental.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/users")
public class UserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
        request.setAttribute("activeMenu", "users");
        request.getRequestDispatcher("/WEB-INF/views/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equalsIgnoreCase(action)) {
            handleCreateUser(request, response);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDeleteUser(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/users");
        }
    }

    private void handleCreateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Username and Password are required.");
            response.sendRedirect(request.getContextPath() + "/users");
            return;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setFullName(fullName != null ? fullName.trim() : username.trim());
        user.setRole(role != null ? role.trim() : "Staff");

        boolean created = userDAO.createUser(user, password.trim());
        if (created) {
            request.getSession().setAttribute("successMessage", "User '" + username + "' created successfully!");
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to create user. Username may already exist.");
        }
        response.sendRedirect(request.getContextPath() + "/users");
    }

    private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
