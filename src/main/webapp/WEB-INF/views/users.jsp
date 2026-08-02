<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="content-card" style="max-width:700px; margin:0 auto 24px auto;">
        <div class="card-title"><i class="fa-solid fa-user-plus"></i> Add New System User Account</div>
        <form action="${pageContext.request.contextPath}/users" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-input" placeholder="e.g. staff2" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Password</label>
                    <input type="password" name="password" class="form-input" placeholder="Enter password" required>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <input type="text" name="fullName" class="form-input" placeholder="e.g. Ruwan Silva" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Role</label>
                    <select name="role" class="form-select" required>
                        <option value="Staff">Staff</option>
                        <option value="Admin">Admin</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top:16px;">
                <i class="fa-solid fa-user-check"></i> Create Account
            </button>
        </form>
    </div>

    <div class="content-card">
        <div class="card-title"><i class="fa-solid fa-users"></i> System Accounts List</div>
        <div class="table-container">
            <table class="table-glass">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Role</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.id}</td>
                            <td style="font-weight:600; color:var(--primary);">${u.username}</td>
                            <td style="font-weight:600;">${u.fullName}</td>
                            <td><span class="badge ${u.role == 'Admin' ? 'badge-completed' : 'badge-pending'}">${u.role}</span></td>
                            <td>
                                <c:if test="${u.username != 'admin'}">
                                    <form action="${pageContext.request.contextPath}/users" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this user?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${u.id}">
                                        <button type="submit" class="btn btn-secondary" style="padding:4px 8px; font-size:0.75rem; width:auto; background:var(--danger); border-color:var(--danger); color:#fff;">
                                            <i class="fa-solid fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
