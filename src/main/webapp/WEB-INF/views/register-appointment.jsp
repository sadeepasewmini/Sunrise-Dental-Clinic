<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="content-card" style="max-width:700px; margin:0 auto;">
        <div class="card-title"><i class="fa-solid fa-calendar-plus"></i> Register New Appointment</div>
        <form action="${pageContext.request.contextPath}/appointments" method="POST">
            <input type="hidden" name="action" value="create">

            <div class="form-group">
                <label class="form-label">Patient Name</label>
                <input type="text" name="patientName" class="form-input" placeholder="Enter patient full name" required>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Contact Number</label>
                    <input type="text" name="patientContact" class="form-input" placeholder="e.g. 0771234567" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <input type="text" name="patientAddress" class="form-input" placeholder="Enter address" required>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Select Dentist</label>
                    <select name="dentistId" class="form-select" required>
                        <option value="">-- Choose Dentist --</option>
                        <c:forEach var="d" items="${dentists}">
                            <option value="${d.id}">${d.name} (${d.specialization}) - LKR <fmt:formatNumber value="${d.consultationFee}" pattern="#,##0.00"/></option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Select Treatment</label>
                    <select name="treatmentId" class="form-select" required>
                        <option value="">-- Choose Treatment --</option>
                        <c:forEach var="t" items="${treatments}">
                            <option value="${t.id}">${t.name} - LKR <fmt:formatNumber value="${t.cost}" pattern="#,##0.00"/></option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Appointment Date</label>
                    <input type="date" name="appointmentDate" class="form-input" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Appointment Time</label>
                    <input type="time" name="appointmentTime" class="form-input" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top:20px;">
                <i class="fa-solid fa-check"></i> Register Appointment
            </button>
        </form>
    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
