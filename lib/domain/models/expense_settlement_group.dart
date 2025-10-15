import 'package:jfk_guys/domain/models/settlement_model.dart';

class ExpenseSettlementGroup {
  final String expenseId;
  final String expenseName;
  final List<Settlement> settlements;

  ExpenseSettlementGroup({
    required this.expenseId,
    required this.expenseName,
    required this.settlements,
  });
}
