<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
        <h2 style="font-size:1.5rem; color:var(--text-main); margin:0;">
            <i class="fa-solid fa-users" style="color:var(--primary); margin-right:8px;"></i> Registered Patients
        </h2>
        <a href="${pageContext.request.contextPath}/patients?action=register" class="btn btn-primary">
            <i class="fa-solid fa-plus"></i> Add New Patient
        </a>
    </div>

    <div class="content-card">
        <div class="table-container">
            <table class="table-glass">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Contact Number</th>
                        <th>Email</th>
                        <th>Address</th>
                        <th>Registered Date</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty patients}">
                            <tr>
                                <td colspan="6" style="text-align:center; padding:20px; color:#666;">No patients registered yet.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="patient" items="${patients}">
                                <tr>
                                    <td style="color:var(--primary);"><strong>#${patient.id}</strong></td>
                                    <td style="font-weight: 500;">${patient.name}</td>
                                    <td>${patient.contactNumber}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty patient.email}"><span style="color:#aaa;">N/A</span></c:when>
                                            <c:otherwise>${patient.email}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${patient.address}</td>
                                    <td><fmt:formatDate value="${patient.createdAt}" pattern="yyyy-MM-dd" /></td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
