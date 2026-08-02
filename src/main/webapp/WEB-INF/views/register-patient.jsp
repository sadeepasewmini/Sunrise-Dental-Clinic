<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="content-card" style="max-width:700px; margin:0 auto;">
        <div class="card-title"><i class="fa-solid fa-user-plus"></i> Register New Patient</div>
        <form action="${pageContext.request.contextPath}/patients" method="POST">
            <input type="hidden" name="action" value="create">

            <div class="form-group">
                <label class="form-label">Full Name</label>
                <input type="text" name="name" class="form-input" placeholder="Enter patient full name" required>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Contact Number</label>
                    <input type="text" name="contactNumber" class="form-input" placeholder="e.g. 0771234567" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email Address (Optional)</label>
                    <input type="email" name="email" class="form-input" placeholder="Enter email address">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Address</label>
                <input type="text" name="address" class="form-input" placeholder="Enter address" required>
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top:20px;">
                <i class="fa-solid fa-check"></i> Register Patient
            </button>
        </form>
    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
