<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon icon-blue"><i class="fa-solid fa-users"></i></div>
            <div class="stat-info">
                <h3>Total Patients</h3>
                <p>${totalPatients}</p>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon icon-green"><i class="fa-solid fa-calendar-check"></i></div>
            <div class="stat-info">
                <h3>Total Appointments</h3>
                <p>${totalAppointments}</p>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon icon-orange"><i class="fa-solid fa-clock"></i></div>
            <div class="stat-info">
                <h3>Pending Appointments</h3>
                <p>${pendingAppointments}</p>
            </div>
        </div>

        <c:if test="${currentUser.role == 'Admin'}">
            <div class="stat-card">
                <div class="stat-icon icon-purple"><i class="fa-solid fa-money-bill-wave"></i></div>
                <div class="stat-info">
                    <h3>Total Revenue</h3>
                    <p>LKR <fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/></p>
                </div>
            </div>
        </c:if>
    </div>

    <c:if test="${currentUser.role == 'Admin'}">
        <div class="content-card" style="margin-top: 24px;">
            <div class="card-title"><i class="fa-solid fa-user-doctor"></i> Revenue by Dentist (Doctor Performance)</div>
            <div style="display:flex; flex-direction:column; gap:16px;">
                <c:forEach var="entry" items="${dentistRevenue}">
                    <div>
                        <div style="display:flex; justify-content:space-between; margin-bottom:6px; font-weight:600; font-size:0.9rem;">
                            <span>${entry.key}</span>
                            <span style="color:var(--primary);">LKR <fmt:formatNumber value="${entry.value}" pattern="#,##0.00"/></span>
                        </div>
                        <div style="width:100%; background:var(--bg-glass); border-radius:8px; height:12px; overflow:hidden;">
                            <c:set var="pct" value="${totalRevenue > 0 ? (entry.value / totalRevenue * 100) : 0}" />
                            <fmt:formatNumber var="formattedPct" value="${pct}" maxFractionDigits="2" />
                            <div class="progress-bar-fill" data-width="${formattedPct}" style="background:linear-gradient(90deg, var(--primary) 0%, var(--primary-dark) 100%); height:100%; border-radius:8px;"></div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                document.querySelectorAll('.progress-bar-fill[data-width]').forEach(function(el) {
                    el.style.width = el.getAttribute('data-width') + '%';
                });
            });
        </script>
    </c:if>

    <div class="content-card" style="margin-top: 24px;">
        <div class="card-title"><i class="fa-solid fa-list-check"></i> Recent Appointments</div>
        <div class="table-container">
            <table class="table-glass">
                <thead>
                    <tr>
                        <th>Appt No</th>
                        <th>Patient Name</th>
                        <th>Dentist</th>
                        <th>Treatment</th>
                        <th>Date &amp; Time</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${recentAppointments}">
                        <tr>
                            <td style="font-weight:600; color:var(--primary);">${a.appointmentNumber}</td>
                            <td style="font-weight:600;">${a.patientName}</td>
                            <td>${a.dentistName}</td>
                            <td>${a.treatmentName}</td>
                            <td>${a.appointmentDate} at ${a.appointmentTime}</td>
                            <td>
                                <span class="badge ${a.status == 'Pending' ? 'badge-pending' : (a.status == 'Completed' ? 'badge-completed' : 'badge-cancelled')}">
                                    ${a.status}
                                </span>
                            </td>
                            <td>
                                <c:if test="${a.status == 'Pending'}">
                                    <form action="${pageContext.request.contextPath}/appointments" method="POST" style="display:inline;">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="id" value="${a.id}">
                                        <input type="hidden" name="status" value="Completed">
                                        <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/dashboard">
                                        <button type="submit" class="btn btn-primary" style="padding:4px 8px; font-size:0.75rem; width:auto;">Complete</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/appointments" method="POST" style="display:inline;">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="id" value="${a.id}">
                                        <input type="hidden" name="status" value="Cancelled">
                                        <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/dashboard">
                                        <button type="submit" class="btn btn-secondary" style="padding:4px 8px; font-size:0.75rem; width:auto; background:var(--danger); border-color:var(--danger); color:#fff;">Cancel</button>
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
