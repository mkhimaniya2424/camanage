import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    const invoices = [
      _InvoiceRow(
        invoiceNumber: 'INV-2024-0056',
        client: 'TechNova Solutions Pvt. Ltd.',
        issueDate: '18 May 2024',
        dueDate: '28 May 2024',
        amount: '₹ 45,000',
        status: 'Sent',
        paymentStatus: 'Pending',
      ),
      _InvoiceRow(
        invoiceNumber: 'INV-2024-0055',
        client: 'GreenLine Traders',
        issueDate: '18 May 2024',
        dueDate: '28 May 2024',
        amount: '₹ 25,000',
        status: 'Sent',
        paymentStatus: 'Paid',
      ),
      _InvoiceRow(
        invoiceNumber: 'INV-2024-0064',
        client: 'Prakash & Co.',
        issueDate: '07 May 2024',
        dueDate: '27 May 2024',
        amount: '₹ 15,000',
        status: 'Draft',
        paymentStatus: '—',
      ),
      _InvoiceRow(
        invoiceNumber: 'INV-2024-0053',
        client: 'Sunrise Enterprises',
        issueDate: '15 May 2024',
        dueDate: '25 May 2024',
        amount: '₹ 60,000',
        status: 'Sent',
        paymentStatus: 'Overdue',
      ),
    ];

    return Scaffold(
      backgroundColor: colors.bg1,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoices',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create, send and manage all your invoices.',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                AppPrimaryButton(
                  label: 'New Invoice',
                  onPressed: () {},
                  width: 180,
                  icon: Icons.receipt_long_rounded,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _MetricCard(title: 'Total Invoices', value: '42', delta: '+12%', color: colors.primary, icon: Icons.receipt_long_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'Paid', value: '18', delta: '+15%', color: colors.success, icon: Icons.check_circle_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'Pending', value: '16', delta: '+5%', color: colors.warning, icon: Icons.pending_actions_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'Overdue', value: '6', delta: '+10%', color: colors.error, icon: Icons.warning_amber_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'Total Amount', value: '₹ 4,85,000', delta: '+18%', color: colors.secondary, icon: Icons.currency_rupee_rounded),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.glassBorderDim),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search invoices...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: TextStyle(color: colors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.bg1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.glassBorderDim),
                    ),
                    child: Row(
                      children: [
                        Text('All Status', style: TextStyle(color: colors.textSecondary)),
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.bg1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.glassBorderDim),
                    ),
                    child: Row(
                      children: [
                        Text('All Clients', style: TextStyle(color: colors.textSecondary)),
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.bg2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.glassBorderDim),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    dataTextStyle: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    columns: const [
                      DataColumn(label: Text('Invoice #')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Issue Date')),
                      DataColumn(label: Text('Due Date')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Payment Status')),
                    ],
                    rows: invoices
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Text(item.invoiceNumber)),
                              DataCell(Text(item.client)),
                              DataCell(Text(item.issueDate)),
                              DataCell(Text(item.dueDate)),
                              DataCell(Text(item.amount)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _statusColor(item.status, colors),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: TextStyle(
                                      color: _statusText(item.status, colors),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _paymentColor(item.paymentStatus, colors),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.paymentStatus,
                                    style: TextStyle(
                                      color: _paymentText(item.paymentStatus, colors),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status, AppThemeExtension colors) {
    switch (status) {
      case 'Sent':
        return colors.primary.withValues(alpha: 0.12);
      case 'Draft':
        return colors.warning.withValues(alpha: 0.12);
      default:
        return colors.success.withValues(alpha: 0.12);
    }
  }

  Color _statusText(String status, AppThemeExtension colors) {
    switch (status) {
      case 'Sent':
        return colors.primary;
      case 'Draft':
        return colors.warning;
      default:
        return colors.success;
    }
  }

  Color _paymentColor(String status, AppThemeExtension colors) {
    switch (status) {
      case 'Paid':
        return colors.success.withValues(alpha: 0.12);
      case 'Overdue':
        return colors.error.withValues(alpha: 0.12);
      default:
        return colors.warning.withValues(alpha: 0.12);
    }
  }

  Color _paymentText(String status, AppThemeExtension colors) {
    switch (status) {
      case 'Paid':
        return colors.success;
      case 'Overdue':
        return colors.error;
      default:
        return colors.warning;
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String delta;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.glassBorderDim),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24)),
                  const SizedBox(height: 2),
                  Text(delta, style: TextStyle(color: colors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow {
  const _InvoiceRow({
    required this.invoiceNumber,
    required this.client,
    required this.issueDate,
    required this.dueDate,
    required this.amount,
    required this.status,
    required this.paymentStatus,
  });

  final String invoiceNumber;
  final String client;
  final String issueDate;
  final String dueDate;
  final String amount;
  final String status;
  final String paymentStatus;
}
