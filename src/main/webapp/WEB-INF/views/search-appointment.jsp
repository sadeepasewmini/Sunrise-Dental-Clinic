<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="content-card">
        <div class="card-title"><i class="fa-solid fa-magnifying-glass"></i> Search Appointment</div>
        <form action="${pageContext.request.contextPath}/appointments" method="GET" style="display:flex; gap:10px;">
            <input type="hidden" name="action" value="search">
            <input type="text" name="query" class="form-input" value="${query}" placeholder="Search by Appointment Number or Patient Name (e.g. APT-0001, Sadeepa)" style="flex-grow:1;" required>
            <button type="submit" class="btn btn-primary" style="width:auto;">
                <i class="fa-solid fa-search"></i> Search
            </button>
        </form>
    </div>

    <c:if test="${not empty searchResults}">
        <div class="content-card" style="margin-top:20px;">
            <div class="card-title"><i class="fa-solid fa-list-check"></i> Matching Appointments (${searchResults.size()})</div>
            <div class="table-container">
                <table class="table-glass">
                    <thead>
                        <tr>
                            <th>Appt No</th>
                            <th>Patient Name</th>
                            <th>Contact</th>
                            <th>Address</th>
                            <th>Dentist</th>
                            <th>Treatment</th>
                            <th>Date &amp; Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${searchResults}">
                            <tr>
                                <td style="font-weight:600; color:var(--primary);">${a.appointmentNumber}</td>
                                <td style="font-weight:600;">${a.patientName}</td>
                                <td>${a.patientContact}</td>
                                <td>${a.patientAddress}</td>
                                <td>${a.dentistName}</td>
                                <td>${a.treatmentName}</td>
                                <td>${a.appointmentDate} at ${a.appointmentTime}</td>
                                <td>
                                    <span class="badge ${a.status == 'Pending' ? 'badge-pending' : (a.status == 'Completed' ? 'badge-completed' : 'badge-cancelled')}">
                                        ${a.status}
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>

    <c:if test="${empty searchResults and not empty query}">
        <div class="alert alert-danger" style="margin-top:20px;">
            <i class="fa-solid fa-circle-xmark"></i> No appointments found matching '${query}'.
        </div>
    </c:if>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
