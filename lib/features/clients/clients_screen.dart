import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    const clients = [
      _ClientRow(
        initials: 'T',
        name: 'TechNova Solutions Pvt. Ltd.',
        email: 'contact@technova.com',
        phone: '+91 98765 43210',
        group: 'Business',
        status: 'Active',
        dueAmount: '₹ 45,000',
        dueText: 'Overdue',
        dueColor: Color(0xFFE74C3C),
      ),
      _ClientRow(
        initials: 'G',
        name: 'GreenLine Traders',
        email: 'greenline@traders.com',
        phone: '+91 91234 56789',
        group: 'Business',
        status: 'Active',
        dueAmount: '₹ 12,500',
        dueText: 'Due in 7 days',
        dueColor: Color(0xFFF0B429),
      ),
      _ClientRow(
        initials: 'P',
        name: 'Prakash & Co.',
        email: 'prakash@co.com',
        phone: '+91 99876 54321',
        group: 'Individual',
        status: 'Active',
        dueAmount: '₹ 0',
        dueText: 'Paid',
        dueColor: Color(0xFF00C48C),
      ),
      _ClientRow(
        initials: 'S',
        name: 'Sunrise Enterprises',
        email: 'hello@sunrise.com',
        phone: '+91 97654 32109',
        group: 'Business',
        status: 'Inactive',
        dueAmount: '₹ 8,000',
        dueText: 'Overdue',
        dueColor: Color(0xFFE74C3C),
      ),
      _ClientRow(
        initials: 'M',
        name: 'Mehta Retailers',
        email: 'mehta@retail.com',
        phone: '+91 93456 78901',
        group: 'Business',
        status: 'Active',
        dueAmount: '₹ 3,200',
        dueText: 'Due in 3 days',
        dueColor: Color(0xFFF0B429),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.bg1,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1100;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clients',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Manage and view all your clients in one place.',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.upload_file_rounded),
                                label: const Text('Import Clients'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.textPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  side: BorderSide(color: colors.glassBorderDim),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              AppPrimaryButton(
                                label: 'Add Client',
                                onPressed: () {},
                                width: 160,
                                icon: Icons.person_add_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _MetricCard(
                            title: 'Total Clients',
                            value: '128',
                            delta: '+12%',
                            color: colors.primary,
                            icon: Icons.people_alt_rounded,
                          ),
                          const SizedBox(width: 14),
                          _MetricCard(
                            title: 'Active Clients',
                            value: '98',
                            delta: '+8%',
                            color: colors.success,
                            icon: Icons.check_circle_rounded,
                          ),
                          const SizedBox(width: 14),
                          _MetricCard(
                            title: 'Inactive Clients',
                            value: '30',
                            delta: '-4%',
                            color: colors.warning,
                            icon: Icons.pause_circle_rounded,
                          ),
                          const SizedBox(width: 14),
                          _MetricCard(
                            title: 'Client Groups',
                            value: '12',
                            delta: '+5%',
                            color: colors.tertiary,
                            icon: Icons.groups_rounded,
                          ),
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
                                  hintText: 'Search clients by name, email, phone...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintStyle: TextStyle(color: colors.textMuted),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: colors.bg1,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colors.glassBorderDim),
                              ),
                              child: Row(
                                children: [
                                  Text('All Groups', style: TextStyle(color: colors.textSecondary)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: colors.bg1,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colors.glassBorderDim),
                              ),
                              child: Row(
                                children: [
                                  Text('Status', style: TextStyle(color: colors.textSecondary)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.filter_list_rounded, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _ClientTable(clients: clients, colors: colors),
                                  ),
                                  const SizedBox(width: 18),
                                  SizedBox(
                                    width: 330,
                                    child: _ClientDetailCard(colors: colors),
                                  ),
                                ],
                              )
                            : _ClientTable(clients: clients, colors: colors),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
                  Text(
                    title,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    delta,
                    style: TextStyle(
                      color: colors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientTable extends StatelessWidget {
  const _ClientTable({required this.clients, required this.colors});

  final List<_ClientRow> clients;
  final AppThemeExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            DataColumn(label: Text('Client')),
            DataColumn(label: Text('Group')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Due Amount')),
          ],
          rows: clients
              .map(
                (client) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                client.initials,
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(client.name),
                                Text(
                                  client.email,
                                  style: TextStyle(color: colors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(client.group)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor(client.status, colors),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          client.status,
                          style: TextStyle(
                            color: client.status == 'Active' ? colors.primary : colors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.dueAmount),
                          Text(
                            client.dueText,
                            style: TextStyle(
                              color: client.dueColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Color _statusColor(String status, AppThemeExtension colors) {
    if (status == 'Active') {
      return colors.primary.withValues(alpha: 0.12);
    }
    return colors.warning.withValues(alpha: 0.12);
  }
}

class _ClientDetailCard extends StatelessWidget {
  const _ClientDetailCard({required this.colors});

  final AppThemeExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.bg2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.glassBorderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TechNova Solutions',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Business',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoLine(label: 'Client ID', value: 'CLT-000124', colors: colors),
          _InfoLine(label: 'Group', value: 'Business', colors: colors),
          _InfoLine(label: 'Email', value: 'contact@technova.com', colors: colors),
          _InfoLine(label: 'Phone', value: '+91 98765 43210', colors: colors),
          _InfoLine(label: 'Due Amount', value: '₹ 45,000', colors: colors),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Email'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: colors.glassBorderDim),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Invoice'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppThemeExtension colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          Text(value, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ClientRow {
  const _ClientRow({
    required this.initials,
    required this.name,
    required this.email,
    required this.phone,
    required this.group,
    required this.status,
    required this.dueAmount,
    required this.dueText,
    required this.dueColor,
  });

  final String initials;
  final String name;
  final String email;
  final String phone;
  final String group;
  final String status;
  final String dueAmount;
  final String dueText;
  final Color dueColor;
}
