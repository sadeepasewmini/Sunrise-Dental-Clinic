<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Official Invoice - ${appointment.appointmentNumber}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #0f766e;
            --primary-light: #14b8a6;
            --primary-dark: #115e59;
            --accent: #f59e0b;
            --bg-body: #f1f5f9;
            --card-bg: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-dark);
            padding: 40px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .invoice-wrapper {
            width: 100%;
            max-width: 780px;
            background: var(--card-bg);
            border-radius: 20px;
            box-shadow: 0 20px 50px rgba(15, 23, 42, 0.08);
            overflow: hidden;
            border: 1px solid rgba(226, 232, 240, 0.8);
        }

        /* Banner Header */
        .invoice-header {
            background: linear-gradient(135deg, #0f766e 0%, #0d9488 50%, #14b8a6 100%);
            color: #ffffff;
            padding: 32px 36px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
        }

        .clinic-brand {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .clinic-logo-icon {
            width: 52px;
            height: 52px;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.25);
        }

        .clinic-title {
            font-size: 1.6rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            line-height: 1.2;
        }

        .clinic-subtitle {
            font-size: 0.82rem;
            color: rgba(255, 255, 255, 0.85);
            margin-top: 2px;
        }

        .invoice-badge-box {
            text-align: right;
        }

        .invoice-type-tag {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 6px 14px;
            border-radius: 30px;
            font-size: 0.75rem;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-bottom: 6px;
        }

        .invoice-number {
            font-size: 1.1rem;
            font-weight: 700;
        }

        /* Body Details Grid */
        .invoice-body {
            padding: 36px;
        }

        .meta-strip {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 14px 20px;
            margin-bottom: 28px;
            font-size: 0.88rem;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-muted);
        }

        .meta-item strong {
            color: var(--text-dark);
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-paid {
            background: #dcfce7;
            color: #15803d;
            border: 1px solid #bbf7d0;
        }

        .status-unpaid {
            background: #fef3c7;
            color: #b45309;
            border: 1px solid #fde68a;
        }

        /* 2-Column Section Cards */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .info-card {
            background: #f8fafc;
            border-radius: 14px;
            padding: 18px 20px;
            border: 1px solid #e2e8f0;
        }

        .info-card-header {
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--primary);
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .info-card-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 4px;
        }

        .info-card-text {
            font-size: 0.86rem;
            color: var(--text-muted);
            line-height: 1.5;
        }

        /* Line Items Table */
        .items-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-bottom: 28px;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }

        .items-table th {
            background: #f1f5f9;
            color: #475569;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            padding: 14px 18px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .items-table td {
            padding: 14px 18px;
            font-size: 0.92rem;
            border-bottom: 1px solid #f1f5f9;
            color: var(--text-dark);
        }

        .items-table tr:last-child td {
            border-bottom: none;
        }

        .row-label {
            font-weight: 600;
        }

        .row-subtext {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-top: 2px;
        }

        .text-right {
            text-align: right !important;
        }

        /* Invoice Summary Box */
        .summary-card {
            background: linear-gradient(135deg, #f0fdf4 0%, #e6fffa 100%);
            border: 1px solid #bbf7d0;
            border-radius: 14px;
            padding: 20px 24px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 30px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.92rem;
            color: #334155;
        }

        .summary-row.total-base {
            font-weight: 600;
            padding-bottom: 8px;
            border-bottom: 1px dashed #cbd5e1;
        }

        .summary-row.discount {
            color: #16a34a;
            font-weight: 600;
            padding-bottom: 8px;
            border-bottom: 1px dashed #cbd5e1;
        }

        .summary-row.net-payable {
            font-size: 1.25rem;
            font-weight: 800;
            color: #0f766e;
            padding-top: 4px;
        }

        /* Footer & Signatures */
        .invoice-footer {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            padding-top: 20px;
            border-top: 1px dashed #cbd5e1;
            margin-top: 20px;
        }

        .footer-note {
            font-size: 0.82rem;
            color: var(--text-muted);
            line-height: 1.5;
            max-width: 380px;
        }

        .signature-box {
            text-align: center;
        }

        .signature-line {
            width: 160px;
            border-top: 1.5px solid #94a3b8;
            margin-bottom: 6px;
        }

        .signature-title {
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
        }

        /* Floating Action Bar */
        .action-bar {
            margin-top: 24px;
            display: flex;
            justify-content: center;
            gap: 14px;
        }

        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.92rem;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            border: none;
        }

        .btn-print {
            background: linear-gradient(135deg, #0f766e, #0d9488);
            color: #ffffff;
            box-shadow: 0 4px 14px rgba(13, 148, 136, 0.3);
        }

        .btn-print:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(13, 148, 136, 0.4);
        }

        .btn-back {
            background: #64748b;
            color: #ffffff;
        }

        .btn-back:hover {
            background: #475569;
            transform: translateY(-2px);
        }

        /* Print Media Styles */
        @media print {
            body {
                background: #ffffff;
                padding: 0;
            }

            .invoice-wrapper {
                box-shadow: none;
                border: none;
                border-radius: 0;
                max-width: 100%;
            }

            .action-bar {
                display: none !important;
            }
        }
    </style>
</head>
<body>

<div>
    <div class="invoice-wrapper">
        <!-- Clinic Banner Header -->
        <div class="invoice-header">
            <div class="clinic-brand">
                <div class="clinic-logo-icon">
                    <i class="fa-solid fa-tooth"></i>
                </div>
                <div>
                    <div class="clinic-title">Sunrise Dental Clinic</div>
                    <div class="clinic-subtitle">No. 45, Flower Road, Colombo 07 | Tel: +94 11 234 5678</div>
                </div>
            </div>
            <div class="invoice-badge-box">
                <div class="invoice-type-tag">Official Invoice</div>
                <div class="invoice-number">${appointment.appointmentNumber}</div>
            </div>
        </div>

        <!-- Main Invoice Content -->
        <div class="invoice-body">
            <!-- Meta Bar -->
            <div class="meta-strip">
                <div class="meta-item">
                    <i class="fa-solid fa-calendar-day" style="color:var(--primary);"></i>
                    <span>Date: <strong>${appointment.appointmentDate}</strong></span>
                </div>
                <div class="meta-item">
                    <i class="fa-solid fa-hashtag" style="color:var(--primary);"></i>
                    <span>Bill No: <strong>INV-${bill != null ? bill.id : '0000'}</strong></span>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${bill != null and bill.status == 'Paid'}">
                            <span class="status-badge status-paid"><i class="fa-solid fa-circle-check"></i> PAID</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-badge status-unpaid"><i class="fa-solid fa-clock"></i> UNPAID</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Patient & Doctor Information Cards -->
            <div class="info-grid">
                <div class="info-card">
                    <div class="info-card-header">
                        <i class="fa-solid fa-user"></i> Patient Details
                    </div>
                    <div class="info-card-title">${appointment.patientName}</div>
                    <div class="info-card-text">
                        <i class="fa-solid fa-phone" style="font-size:0.75rem; margin-right:4px;"></i> ${appointment.patientContact}<br>
                        <i class="fa-solid fa-location-dot" style="font-size:0.75rem; margin-right:4px;"></i> ${appointment.patientAddress}
                    </div>
                </div>

                <div class="info-card">
                    <div class="info-card-header">
                        <i class="fa-solid fa-user-doctor"></i> Doctor &amp; Treatment
                    </div>
                    <div class="info-card-title">${appointment.dentistName}</div>
                    <div class="info-card-text">
                        <strong>Treatment:</strong> ${appointment.treatmentName}<br>
                        <strong>Appt Time:</strong> ${appointment.appointmentTime}
                    </div>
                </div>
            </div>

            <!-- Detailed Charge Table -->
            <table class="items-table">
                <thead>
                    <tr>
                        <th>Item Description</th>
                        <th class="text-right">Amount (LKR)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <div class="row-label">Treatment Charge</div>
                            <div class="row-subtext">${appointment.treatmentName}</div>
                        </td>
                        <td class="text-right row-label">
                            LKR <fmt:formatNumber value="${bill != null ? bill.treatmentCost : appointment.treatmentPrice}" pattern="#,##0.00"/>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="row-label">Dentist Charge</div>
                            <div class="row-subtext">${appointment.dentistName}</div>
                        </td>
                        <td class="text-right row-label">
                            LKR <fmt:formatNumber value="${bill != null ? bill.consultationFee : 0}" pattern="#,##0.00"/>
                        </td>
                    </tr>
                </tbody>
            </table>

            <!-- Financial Summary Box -->
            <div class="summary-card">
                <div class="summary-row total-base">
                    <span>Total Base Fee</span>
                    <span>LKR <fmt:formatNumber value="${bill != null ? bill.totalCost : appointment.treatmentPrice}" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-row discount">
                    <span>Total Discount</span>
                    <span>- LKR <fmt:formatNumber value="${bill != null ? bill.discountAmount : 0}" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-row net-payable">
                    <span>Net Payable Amount</span>
                    <span>LKR <fmt:formatNumber value="${bill != null ? bill.netCost : appointment.treatmentPrice}" pattern="#,##0.00"/></span>
                </div>
            </div>

            <!-- Footer & Signature Block -->
            <div class="invoice-footer">
                <div class="footer-note">
                    <p style="font-weight:600; color:var(--text-dark); margin-bottom:4px;">Thank you for choosing Sunrise Dental Clinic!</p>
                    <p>Keep your smile healthy and vibrant. If you have any inquiries regarding this invoice, please contact our helpline.</p>
                </div>
                <div class="signature-box">
                    <div class="signature-line"></div>
                    <div class="signature-title">Authorized Signature</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Floating Action Buttons -->
    <div class="action-bar">
        <button onclick="window.print()" class="btn-action btn-print">
            <i class="fa-solid fa-print"></i> Print Official Receipt
        </button>
        <a href="${pageContext.request.contextPath}/billing" class="btn-action btn-back">
            <i class="fa-solid fa-arrow-left"></i> Return to Billing
        </a>
    </div>
</div>

</body>
</html>
