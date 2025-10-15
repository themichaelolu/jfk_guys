import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/constants/app_colors.dart';
import 'package:jfk_guys/domain/providers/firestore_service_provider.dart';
import 'package:jfk_guys/features/expense_list_screen.dart';
import 'package:jfk_guys/features/home_screen.dart';
import '../domain/models/expense_model.dart';
import '../domain/models/participant.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String splitId;
  final String splitName;
  final List<Participant> friends;

  const AddExpenseScreen({
    super.key,
    required this.splitId,
    required this.friends,
    required this.splitName,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String description = '';
  String amount = '';
  String paidBy = '';
  bool splitEqually = false;

  final Map<String, double> customShares = {};
  final List<String> selectedParticipants = [];

  late final AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  // Helper: round to cents
  double _roundToCents(double v) => (v * 100).roundToDouble() / 100.0;

  double get totalCustomShare =>
      _roundToCents(customShares.values.fold(0.0, (s, v) => s + v));

  bool get _customSharesMatchTotal {
    final parsed = double.tryParse(amount) ?? 0.0;
    return (totalCustomShare - parsed).abs() < 0.01;
  }

  void _toggleParticipant(String name) {
    setState(() {
      if (selectedParticipants.contains(name)) {
        selectedParticipants.remove(name);
        customShares.remove(name);
      } else {
        selectedParticipants.add(name);
      }

      // Reinitialize shares when participants change (only in custom mode)
      final parsed = double.tryParse(amount) ?? 0.0;
      if (!splitEqually && parsed > 0 && selectedParticipants.isNotEmpty) {
        _initEqualShares(parsed);
      }
    });
  }

  void _initEqualShares(double totalAmount) {
    if (selectedParticipants.isEmpty) return;
    final perHead = _roundToCents(totalAmount / selectedParticipants.length);
    setState(() {
      for (var p in selectedParticipants) {
        customShares[p] = perHead;
      }
      // fix rounding difference by adjusting the first participant
      final sum = customShares.values.fold(0.0, (s, v) => s + v);
      final diff = _roundToCents(totalAmount - sum);
      if (diff != 0) {
        final first = selectedParticipants.first;
        customShares[first] = _roundToCents((customShares[first] ?? 0) + diff);
      }
    });
  }

  // Called when amount text changes
  void _onAmountChanged(String v) {
    setState(() => amount = v);
    final parsed = double.tryParse(v) ?? 0.0;
    if (!splitEqually && parsed > 0 && selectedParticipants.isNotEmpty) {
      _initEqualShares(parsed);
    }
  }

  /// When user moves a single participant's slider:
  /// - Set that participant to newValue (rounded)
  /// - Redistribute remaining amount across others proportionally to their previous shares
  /// - If others had zero total, distribute remaining equally
  /// - Fix rounding diff to keep total exact
  void _updateShare(String participant, double newValue, double totalAmount) {
    if (!selectedParticipants.contains(participant)) return;

    setState(() {
      final T = _roundToCents(totalAmount);
      var nv = _roundToCents(newValue.clamp(0.0, T));
      // set new value
      customShares[participant] = nv;

      final others = selectedParticipants
          .where((p) => p != participant)
          .toList();
      final remaining = _roundToCents(T - nv);

      if (others.isEmpty) {
        // only one participant -> absorb all
        customShares[participant] = T;
      } else {
        // compute total of others before change
        double totalOtherOld = 0.0;
        for (var o in others) {
          totalOtherOld += (customShares[o] ?? 0.0);
        }

        if (totalOtherOld <= 0.0) {
          // distribute equally
          final per = _roundToCents(remaining / others.length);
          for (var o in others) {
            customShares[o] = per;
          }
        } else {
          final scale = remaining / totalOtherOld;
          for (var o in others) {
            customShares[o] = _roundToCents((customShares[o] ?? 0.0) * scale);
          }
        }
      }

      // Fix rounding diff
      final sumAll = _roundToCents(
        customShares.values.fold(0.0, (s, v) => s + v),
      );
      final diff = _roundToCents(T - sumAll);
      if (diff != 0) {
        // Prefer to adjust the moved participant (keeps immediate UI predictable)
        customShares[participant] = _roundToCents(
          (customShares[participant] ?? 0) + diff,
        );
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        paidBy.isEmpty ||
        selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final totalAmount = double.tryParse(amount);
    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    if (!splitEqually && !_customSharesMatchTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Custom shares must equal total amount")),
      );
      return;
    }

    final shares = splitEqually
        ? {
            for (var p in selectedParticipants)
              p: _roundToCents(totalAmount / selectedParticipants.length),
          }
        : Map<String, double>.from(customShares);

    final expense = Expense(
      id: '',
      description: description,
      amount: _roundToCents(totalAmount),
      paidBy: paidBy,
      participants: selectedParticipants,
      date: DateTime.now(),
      category: "Other",
      shares: shares,
    );

    try {
      final service = ref.read(firestoreServiceProvider);
      await service.addExpense(widget.splitId, expense);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense added successfully!")),
      );
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => ExpenseListScreen(
            splitId: widget.splitId,
            splitName: widget.splitName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedAmount = double.tryParse(amount) ?? 0.0;
    final assigned = totalCustomShare;
    final remaining = _roundToCents(parsedAmount - assigned);
    final assignedOk = splitEqually || _customSharesMatchTotal;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Expense"),
            Text(
              widget.splitName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Amount *",
                        prefixText: "₦ ",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: _onAmountChanged,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter an amount" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Description *",
                        border: OutlineInputBorder(),
                        hintText: "e.g. Dinner at restaurant",
                      ),
                      onChanged: (v) => description = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter a description" : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Who Paid? *",
                        border: OutlineInputBorder(),
                      ),
                      value: paidBy.isNotEmpty ? paidBy : null,
                      items: widget.friends
                          .map(
                            (f) => DropdownMenuItem(
                              value: f.name,
                              child: Text(f.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => paidBy = v ?? ''),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Select who paid" : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Participants selector
            Text(
              "Participants",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.friends.map((f) {
                final selected = selectedParticipants.contains(f.name);
                return ChoiceChip(
                  label: Text(f.name),
                  selected: selected,
                  onSelected: (_) => _toggleParticipant(f.name),
                  selectedColor: AppColors.primaryColor.withOpacity(0.12),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Split mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Split Equally"),
                Switch(
                  value: splitEqually,
                  onChanged: (v) {
                    setState(() {
                      splitEqually = v;
                      // if switching to custom, init shares
                      final parsed = double.tryParse(amount) ?? 0.0;
                      if (!splitEqually &&
                          parsed > 0 &&
                          selectedParticipants.isNotEmpty) {
                        _initEqualShares(parsed);
                      }
                      if (splitEqually) {
                        // clear custom shares when switching back to equal
                        customShares.clear();
                      }
                    });
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Info / per-head text (equal)
            if (splitEqually &&
                selectedParticipants.isNotEmpty &&
                parsedAmount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "Each pays: ₦${_roundToCents(parsedAmount / selectedParticipants.length).toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            // Custom sliders
            if (!splitEqually)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedParticipants.isEmpty)
                    const Text("Select participants to set custom shares."),
                  if (selectedParticipants.isNotEmpty && parsedAmount <= 0)
                    const Text("Enter a valid amount to set shares."),
                  if (selectedParticipants.isNotEmpty && parsedAmount > 0)
                    ...selectedParticipants.map((p) {
                      final value = customShares[p] ?? 0.0;
                      final percent = parsedAmount > 0
                          ? (value / parsedAmount * 100).toStringAsFixed(0)
                          : "0";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  p,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  "₦${currencyFormat.format(value)} ($percent%)",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Slider(
                              value: value.clamp(0.0, parsedAmount),
                              min: 0,
                              max: parsedAmount,
                              onChanged: (val) =>
                                  _updateShare(p, val, parsedAmount),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  // total assigned indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Total assigned: ₦${currencyFormat.format(assigned)} / ₦${currencyFormat.format(parsedAmount)}"
                      "${parsedAmount > 0 ? (remaining == 0 ? ' — All assigned' : ' — Remaining ₦${remaining.toStringAsFixed(2)}') : ''}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: assignedOk ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Save button
            ScaleTransition(
              scale: _buttonController,
              child: ElevatedButton(
                onPressed: (!splitEqually && !assignedOk)
                    ? null
                    : () async {
                        if (_buttonController.isAnimating) return;
                        await _buttonController.reverse();
                        await _buttonController.forward();
                        _submit();
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text(
                  "Save Expense",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
