<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp" />

<section class="page-section">
    <div class="content-card" style="max-width:700px; margin:0 auto;">
        <div class="card-title"><i class="fa-solid fa-calculator"></i> Calculate &amp; Generate Bill</div>
        
        <form action="${pageContext.request.contextPath}/billing" method="POST">
            <input type="hidden" name="action" value="calculate">
            <div class="form-group">
                <label class="form-label">Appointment Number</label>
                <input type="text" name="appointmentNumber" class="form-input" value="${appointment != null ? appointment.appointmentNumber : ''}" placeholder="Enter Appointment Number (e.g. APT-0001)" required>
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">Billing Strategy</label>
                    <select name="billingStrategy" class="form-select">
                        <option value="default" ${selectedStrategy == 'default' ? 'selected' : ''}>Standard (Full Fee)</option>
                        <option value="discount" ${selectedStrategy == 'discount' ? 'selected' : ''}>Discount Strategy (10% Off)</option>
                        <option value="insurance" ${selectedStrategy == 'insurance' ? 'selected' : ''}>Insurance Coverage (50% Off)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Additional Manual Discount (LKR)</label>
                    <input type="number" name="manualDiscount" class="form-input" value="${manualDiscount != null ? manualDiscount : 0}" step="0.01">
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top:16px;">
                <i class="fa-solid fa-calculator"></i> Calculate Bill
            </button>
        </form>

        <c:if test="${not empty bill and not empty appointment}">
            <hr style="margin:24px 0; border:none; border-top:1px solid rgba(0,0,0,0.1);">
            <div style="background:var(--bg-glass); border-radius:16px; padding:24px; border:1px solid rgba(8, 145, 178, 0.2); box-shadow: 0 8px 24px rgba(0,0,0,0.05);">
                <h4 style="margin:0 0 16px 0; color:var(--primary); font-size:1.15rem; font-weight:700;"><i class="fa-solid fa-file-invoice-dollar"></i> Invoice Summary</h4>
                
                <div style="display:flex; flex-direction:column; gap:10px; font-size:0.95rem; line-height:1.6;">
                    <div style="display:flex; justify-content:space-between; padding-bottom:8px; border-bottom:1px solid rgba(0,0,0,0.06);">
                        <span style="color:var(--text-muted); font-weight:600;">Patient Name:</span>
                        <span style="font-weight:700; color:var(--text-main);">${appointment.patientName}</span>
                    </div>

                    <div style="display:flex; justify-content:space-between; padding-bottom:8px; border-bottom:1px solid rgba(0,0,0,0.06);">
                        <span style="color:var(--text-muted); font-weight:600;">Treatment:</span>
                        <span style="font-weight:600;">${appointment.treatmentName}</span>
                    </div>

                    <div style="display:flex; justify-content:space-between; padding-bottom:8px; border-bottom:1px solid rgba(0,0,0,0.06);">
                        <span style="color:var(--text-muted); font-weight:600;">Treatment Charge:</span>
                        <span style="font-weight:600;">LKR <fmt:formatNumber value="${bill.treatmentCost}" pattern="#,##0.00"/></span>
                    </div>

                    <div style="display:flex; justify-content:space-between; padding-bottom:8px; border-bottom:1px solid rgba(0,0,0,0.06);">
                        <span style="color:var(--text-muted); font-weight:600;">Dentist:</span>
                        <span style="font-weight:600;">${appointment.dentistName}</span>
                    </div>

                    <div style="display:flex; justify-content:space-between; padding-bottom:8px; border-bottom:1px solid rgba(0,0,0,0.06);">
                        <span style="color:var(--text-muted); font-weight:600;">Dentist Charge:</span>
                        <span style="font-weight:600;">LKR <fmt:formatNumber value="${bill.consultationFee}" pattern="#,##0.00"/></span>
                    </div>

                    <div style="display:flex; justify-content:space-between; padding-bottom:8px; border-bottom:1px solid rgba(0,0,0,0.06); font-weight:700;">
                        <span style="color:var(--text-main);">Total Base Fee:</span>
                        <span style="color:var(--text-main);">LKR <fmt:formatNumber value="${bill.totalCost}" pattern="#,##0.00"/></span>
                    </div>

                    <div style="display:flex; justify-content:space-between; padding-bottom:8px; border-bottom:1px solid rgba(0,0,0,0.06); color:var(--primary); font-weight:600;">
                        <span>Total Discount:</span>
                        <span>- LKR <fmt:formatNumber value="${bill.discountAmount}" pattern="#,##0.00"/></span>
                    </div>

                    <div style="display:flex; justify-content:space-between; padding-top:8px; font-size:1.2rem; font-weight:700; color:var(--success);">
                        <span>Net Payable Amount:</span>
                        <span>LKR <fmt:formatNumber value="${bill.netCost}" pattern="#,##0.00"/></span>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/billing" method="POST" style="margin-top:24px;">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="appointmentNumber" value="${appointment.appointmentNumber}">
                    <input type="hidden" name="discountAmount" value="${bill.discountAmount}">

                    <div style="display:flex; gap:12px;">
                        <button type="submit" name="paymentStatus" value="Paid" class="btn btn-primary" style="background:#10b981; border-color:#10b981; flex:1; padding:14px; font-size:1rem; font-weight:700; border-radius:10px; cursor:pointer;">
                            <i class="fa-solid fa-circle-check"></i> Paid
                        </button>
                        <button type="submit" name="paymentStatus" value="Unpaid" class="btn btn-secondary" style="background:#ef4444; border-color:#ef4444; color:#fff; flex:1; padding:14px; font-size:1rem; font-weight:700; border-radius:10px; cursor:pointer;">
                            <i class="fa-solid fa-circle-xmark"></i> Unpaid
                        </button>
                    </div>
                </form>
            </div>
        </c:if>
    </div>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp" />
