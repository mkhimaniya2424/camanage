import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    const tasks = [
      _TaskRow(
        task: 'Prepare and file GST Return - May 2024',
        client: 'TechNova Solutions Pvt. Ltd.',
        assignee: 'Meghana K',
        priority: 'High',
        dueDate: '20 May 2024',
        status: 'Pending',
        category: 'GST Compliance',
      ),
      _TaskRow(
        task: 'Audit Documents Review',
        client: 'GreenLine Traders',
        assignee: 'Rohit Sharma',
        priority: 'Medium',
        dueDate: '22 May 2024',
        status: 'In Progress',
        category: 'Audit',
      ),
      _TaskRow(
        task: 'ITR Filing for FY 2023-24',
        client: 'Prakash & Co.',
        assignee: 'Meghana K',
        priority: 'High',
        dueDate: '25 May 2024',
        status: 'Pending',
        category: 'Income Tax',
      ),
      _TaskRow(
        task: 'Reconcile Bank Statements',
        client: 'Sunrise Enterprises',
        assignee: 'Aditi Verma',
        priority: 'Low',
        dueDate: '28 May 2024',
        status: 'In Progress',
        category: 'Accounting',
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
                      'Tasks',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Organize and track all your tasks efficiently.',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                AppPrimaryButton(
                  label: 'New Task',
                  onPressed: () {},
                  width: 160,
                  icon: Icons.add_task_rounded,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _MetricCard(title: 'Total Tasks', value: '48', delta: '+12%', color: colors.primary, icon: Icons.task_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'Pending', value: '18', delta: '+8%', color: colors.warning, icon: Icons.pending_actions_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'In Progress', value: '12', delta: '+5%', color: colors.secondary, icon: Icons.work_history_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'Completed', value: '15', delta: '+15%', color: colors.success, icon: Icons.check_circle_rounded),
                const SizedBox(width: 14),
                _MetricCard(title: 'Overdue', value: '3', delta: '+25%', color: colors.error, icon: Icons.warning_amber_rounded),
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
                        hintText: 'Search tasks...',
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
                        Text('All Priority', style: TextStyle(color: colors.textSecondary)),
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
                      DataColumn(label: Text('Task')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Assignee')),
                      DataColumn(label: Text('Priority')),
                      DataColumn(label: Text('Due Date')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Category')),
                    ],
                    rows: tasks
                        .map(
                          (task) => DataRow(
                            cells: [
                              DataCell(Text(task.task)),
                              DataCell(Text(task.client)),
                              DataCell(Text(task.assignee)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _priorityColor(task.priority, colors),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.priority,
                                    style: TextStyle(
                                      color: _priorityTextColor(task.priority, colors),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(task.dueDate)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _statusColor(task.status, colors),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.status,
                                    style: TextStyle(
                                      color: _statusTextColor(task.status, colors),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(task.category)),
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

  Color _priorityColor(String priority, AppThemeExtension colors) {
    switch (priority) {
      case 'High':
        return colors.error.withValues(alpha: 0.12);
      case 'Medium':
        return colors.warning.withValues(alpha: 0.12);
      default:
        return colors.primary.withValues(alpha: 0.12);
    }
  }

  Color _priorityTextColor(String priority, AppThemeExtension colors) {
    switch (priority) {
      case 'High':
        return colors.error;
      case 'Medium':
        return colors.warning;
      default:
        return colors.primary;
    }
  }

  Color _statusColor(String status, AppThemeExtension colors) {
    switch (status) {
      case 'Pending':
        return colors.warning.withValues(alpha: 0.12);
      case 'In Progress':
        return colors.tertiary.withValues(alpha: 0.12);
      default:
        return colors.success.withValues(alpha: 0.12);
    }
  }

  Color _statusTextColor(String status, AppThemeExtension colors) {
    switch (status) {
      case 'Pending':
        return colors.warning;
      case 'In Progress':
        return colors.tertiary;
      default:
        return colors.success;
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

class _TaskRow {
  const _TaskRow({
    required this.task,
    required this.client,
    required this.assignee,
    required this.priority,
    required this.dueDate,
    required this.status,
    required this.category,
  });

  final String task;
  final String client;
  final String assignee;
  final String priority;
  final String dueDate;
  final String status;
  final String category;
}
