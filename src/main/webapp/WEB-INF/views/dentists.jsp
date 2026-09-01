<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <!-- Form to Add New Dentist -->
    <div class="content-card">
        <div class="card-title">
            <i class="fa-solid fa-user-doctor"></i> Add New Dentist / Doctor
        </div>
        
        <form action="${pageContext.request.contextPath}/dentists" method="POST" id="addDentistForm">
            <input type="hidden" name="action" value="create">
            
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label" for="dentistName">Full Name / Doctor Title <span style="color:var(--danger);">*</span></label>
                    <input type="text" id="dentistName" name="name" class="form-input" placeholder="e.g. Dr. Sunil Perera" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="specialization">Specialization <span style="color:var(--danger);">*</span></label>
                    <select id="specialization" name="specialization" class="form-select" required>
                        <option value="" disabled selected>-- Select Specialization --</option>
                        <option value="General Practitioner">General Practitioner / General Dentist</option>
                        <option value="Orthodontist">Orthodontist (Braces &amp; Alignment)</option>
                        <option value="Endodontist">Endodontist (Root Canal Specialist)</option>
                        <option value="Pediatric Dentist">Pediatric Dentist (Child Specialist)</option>
                        <option value="Periodontist">Periodontist (Gum Specialist)</option>
                        <option value="Prosthodontist">Prosthodontist (Dentures &amp; Crowns)</option>
                        <option value="Oral &amp; Maxillofacial Surgeon">Oral &amp; Maxillofacial Surgeon</option>
                        <option value="Cosmetic Dentist">Cosmetic Dentist (Teeth Whitening &amp; Veneers)</option>
                    </select>
                </div>
            </div>

            <div class="grid-2" style="margin-top:12px;">
                <div class="form-group">
                    <label class="form-label" for="contactNumber">Contact Phone Number</label>
                    <input type="text" id="contactNumber" name="contactNumber" class="form-input" placeholder="e.g. 0771234567">
                </div>

                <div class="form-group">
                    <label class="form-label" for="consultationFee">Consultation Fee (LKR) <span style="color:var(--danger);">*</span></label>
                    <input type="number" id="consultationFee" name="consultationFee" class="form-input" value="1000.00" step="50" min="0" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top:20px; width:auto; padding:12px 28px;">
                <i class="fa-solid fa-plus"></i> Add Dentist Profile
            </button>
        </form>
    </div>

    <!-- Dentist List Table -->
    <div class="content-card" style="margin-top: 24px;">
        <div class="card-title">
            <i class="fa-solid fa-list-ul"></i> Registered Dentists (${dentists.size()})
        </div>

        <div class="table-container">
            <table class="table-glass">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Dentist Name</th>
                        <th>Specialization</th>
                        <th>Contact Number</th>
                        <th>Consultation Fee</th>
                        <th style="text-align:center;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="d" items="${dentists}">
                        <tr>
                            <td style="font-weight:600; color:var(--text-muted);">#${d.id}</td>
                            <td style="font-weight:700; color:var(--primary-dark);">
                                <i class="fa-solid fa-user-doctor" style="color:var(--primary); margin-right:6px;"></i> ${d.name}
                            </td>
                            <td>
                                <span class="badge badge-completed" style="background:rgba(8, 145, 178, 0.15); color:var(--primary); font-weight:600;">
                                    ${d.specialization}
                                </span>
                            </td>
                            <td>${d.contactNumber != null && !d.contactNumber.isEmpty() ? d.contactNumber : 'N/A'}</td>
                            <td style="font-weight:700; color:var(--success);">
                                LKR <fmt:formatNumber value="${d.consultationFee}" pattern="#,##0.00"/>
                            </td>
                            <td style="text-align:center;">
                                <form action="${pageContext.request.contextPath}/dentists" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to remove ${d.name}?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${d.id}">
                                    <button type="submit" class="btn btn-secondary" style="padding:6px 14px; font-size:0.8rem; background:var(--danger); border-color:var(--danger); color:#fff; border-radius:8px;">
                                        <i class="fa-solid fa-trash"></i> Remove
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty dentists}">
                        <tr>
                            <td colspan="6" style="text-align:center; padding:24px; color:var(--text-muted);">
                                No dentists registered yet.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
