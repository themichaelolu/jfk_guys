import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jfk_guys/constants/app_colors.dart';
import 'package:jfk_guys/domain/models/participant.dart';
import 'package:jfk_guys/domain/providers/firestore_service_provider.dart';
import 'package:jfk_guys/features/add_participants_screen.dart';
import 'package:jfk_guys/features/expense_card.dart';
import 'package:jfk_guys/features/home_screen.dart';
import 'package:jfk_guys/features/summary_screen.dart' hide currencyFormat;
import 'package:jfk_guys/utils/alert_dialog_ui.dart';

import 'add_expense_screen.dart';

class ExpenseListScreen extends ConsumerWidget {
  final String splitId;
  final String splitName;

  const ExpenseListScreen({
    super.key,
    required this.splitId,
    required this.splitName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider(splitId));
    final expensesAsync = ref.watch(expensesProvider(splitId));
    final participants = participantsAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(splitName),
            Text(
              "${participants.length} participants • ${expenses.length} expenses",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(
                    splitId: splitId,
                    friends: participants,
                    splitName: splitName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          final participants = participantsAsync.value ?? [];
          final totalAmount = expenses.fold<double>(
            0,
            (sum, e) => sum + e.amount,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600; // breakpoint

              if (expenses.isEmpty) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SummaryCard(
                        participants: participants,
                        totalAmount: totalAmount,
                        splitId: splitId,
                        splitName: splitName,
                        isWide: isWide,
                      ),
                      const SizedBox(height: 16),
                      RecieptsEmptyWidget(
                        participants: participants,
                        splitId: splitId,
                        splitName: splitName,
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCard(
                    participants: participants,
                    totalAmount: totalAmount,
                    splitId: splitId,
                    splitName: splitName,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Expenses",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => AddExpenseScreen(
                                splitId: splitId,
                                friends: participants,
                                splitName: splitName,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        label: Text(
                          'Add Expenses',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...expenses.reversed.map((expense) {
                    return ExpenseCard(
                      splitId: splitId,
                      expense: expense,
                      participants: participants,
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<Participant> participants;
  final double totalAmount;
  final String splitId;
  final String splitName;
  final bool isWide;

  const _SummaryCard({
    required this.participants,
    required this.totalAmount,
    required this.splitId,
    required this.splitName,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.surface;
    final avg = participants.isNotEmpty
        ? totalAmount / participants.length
        : 0.0;

    final formattedAvg = NumberFormat("#,##0.00", "en_US").format(avg);

    final content = [
      Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Expenses", style: theme.textTheme.bodyMedium),
          Text(
            'NGN ${currencyFormat.format(totalAmount)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Average per person: NGN $formattedAvg",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
      SizedBox(height: 10),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SummaryScreen(splitId: splitId, splitName: splitName),
            ),
          );
        },
        icon: Icon(Icons.visibility, color: color),
        label: Text(
          "View Summary",
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ),
      SizedBox(height: 10),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddParticipantsScreen(splitId: splitId, splitName: splitName),
            ),
          );
        },
        icon: Icon(CupertinoIcons.person_fill, color: color),
        label: Text(
          "Edit participants",
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: content,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
    );
  }
}

class RecieptsEmptyWidget extends StatelessWidget {
  const RecieptsEmptyWidget({
    super.key,
    required this.participants,
    required this.splitId,
    required this.splitName,
  });

  final List<Participant> participants;
  final String splitId;
  final String splitName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final txt = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = 360.0;
        final scale = (constraints.maxWidth / baseWidth).clamp(0.85, 1.25);

        final titleStyle = txt.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
          fontSize: (16 * scale),
        );
        final metaStyle = txt.bodySmall?.copyWith(
          color: cs.onSurface.withOpacity(0.75),
          fontSize: (12 * scale),
        );

        final borderRadius = BorderRadius.circular(12 * scale);
        final padding = EdgeInsets.all(16 * scale);

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth < 500
                ? constraints.maxWidth
                : 500, // prevent overstretch
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: borderRadius,
            ),
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                Text("No expenses yet", style: titleStyle),
                const SizedBox(height: 6),
                Text(
                  "Start by adding your first expense to this split.",
                  style: metaStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final friends = participants;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExpenseScreen(
                          splitId: splitId,
                          friends: friends,
                          splitName: splitName,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  label: Text(
                    "Add First Expense",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
