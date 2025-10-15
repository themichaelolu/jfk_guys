import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jfk_guys/domain/providers/firestore_service_provider.dart';
import 'package:jfk_guys/features/home_screen.dart';
import 'package:jfk_guys/utils/alert_dialog_ui.dart';
import '../domain/models/expense_model.dart';
import '../domain/models/participant.dart';

class ExpenseCard extends ConsumerWidget {
  final Expense expense;
  final String? splitId;
  final List<Participant> participants;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.splitId,
    required this.participants,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = expense.amount;
    final shares = expense.shares; // participantName -> shareAmount
    final totalShares = shares.values.fold(0.0, (a, b) => a + b);

    // ✅ Only include participants that were involved when the expense was created
    final involvedParticipants = participants
        .where((p) => shares.containsKey(p.name))
        .toList();

    // In case the shares map is empty (fallback)
    final displayParticipants = involvedParticipants.isNotEmpty
        ? involvedParticipants
        : participants;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Top Row: Description + Total Amount ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Description + Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat.yMMMd().format(expense.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Total Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          "NGN ${currencyFormat.format(expense.amount)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Expense"),
                                  content: const Text(
                                    "Are you sure you want to delete this expense?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await ref
                                    .read(firestoreServiceProvider)
                                    .deleteExpense(splitId ?? '', expense.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Expense deleted"),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// --- Paid By ---
            Row(
              children: [
                Text(
                  "Paid by ",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    expense.paidBy.isNotEmpty
                        ? expense.paidBy[0].toUpperCase()
                        : "?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(expense.paidBy, style: const TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 12),

            /// --- Split Details ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Split Details",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),

                // ✅ Show only the involved participants
                ...displayParticipants.map((p) {
                  final share =
                      shares[p.name] ?? (total / displayParticipants.length);
                  final percent = totalShares > 0
                      ? (share / totalShares) * 100
                      : 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar + Name
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: Text(
                                p.name.isNotEmpty
                                    ? p.name[0].toUpperCase()
                                    : "?",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(p.name, style: const TextStyle(fontSize: 14)),
                          ],
                        ),

                        // Individual share and %
                        Text(
                          "NGN ${currencyFormat.format(share)} (${percent.toStringAsFixed(0)}%)",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
