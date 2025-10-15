import 'package:jfk_guys/domain/models/balance_model.dart';
import 'package:jfk_guys/domain/models/expense_model.dart';
import 'package:jfk_guys/domain/models/settlement_model.dart';
import 'package:jfk_guys/domain/models/split_model.dart';
import 'package:jfk_guys/domain/services/firestore_service.dart';

class SummaryData {
  final SplitModel split;
  final List<Expense> expenses;
  final List<Balance> balances;
  final List<Settlement> settlements;
  final double totalExpenses;
  final List<ExpenseSettlementGroup> groupedSettlements;

  SummaryData({
    required this.split,
    required this.expenses,
    required this.balances,
    required this.settlements,
    required this.totalExpenses,
    required this.groupedSettlements,
  });
}
