import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jfk_guys/domain/models/balance_model.dart';
import 'package:jfk_guys/domain/models/expense_model.dart';
import 'package:jfk_guys/domain/models/settlement_model.dart';
import 'package:jfk_guys/domain/models/split_model.dart';
import 'package:jfk_guys/domain/models/participant.dart';
import 'package:jfk_guys/domain/models/summary_data.dart';

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

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Not logged in");
    return user.uid;
  }

  // --------------------------
  // SPLITS
  // --------------------------

  Stream<List<SplitModel>> getSplitsStream() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SplitModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<SplitModel> createSplit(String name) async {
    final docRef = await _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .add({
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'participants': [],
        });

    final snapshot = await docRef.get();
    return SplitModel.fromMap(snapshot.data()!, snapshot.id);
  }

  // --------------------------
  // EXPENSES
  // --------------------------

  Stream<List<Expense>> getExpensesStream(String splitId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Expense.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addExpense(String splitId, Expense expense) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .collection('expenses')
        .add(expense.toMap());
  }

  Stream<SummaryData> watchSummary(String splitId) async* {
    // Listen to both split and expenses in real time
    final splitDoc = _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .snapshots();

    final expensesQuery = _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .collection('expenses')
        .snapshots();

    await for (final _ in expensesQuery) {
      final splitSnapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('splits')
          .doc(splitId)
          .get();

      final split = SplitModel.fromMap(splitSnapshot.data()!, splitSnapshot.id);
      final expensesSnapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('splits')
          .doc(splitId)
          .collection('expenses')
          .get();

      final expenses = expensesSnapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), doc.id))
          .toList();

      yield await getSummary(splitId);
    }
  }

  // --------------------------
  // PARTICIPANTS
  // --------------------------

  Future<void> addParticipant(String splitId, Participant participant) async {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId);

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception('Split not found');

      final data = snapshot.data() ?? {};
      final rawParts = data['participants'] as List<dynamic>? ?? [];
      final parts = rawParts
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final idx = parts.indexWhere((p) => p['id'] == participant.id);
      if (idx >= 0) {
        parts[idx] = participant.toMap();
      } else {
        parts.add(participant.toMap());
      }

      tx.update(docRef, {'participants': parts});
    });
  }

  Future<void> removeParticipant(String splitId, String participantId) async {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId);

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception('Split not found');

      final data = snapshot.data() ?? {};
      final rawParts = data['participants'] as List<dynamic>? ?? [];
      final parts = rawParts
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final updated = parts.where((p) => p['id'] != participantId).toList();
      tx.update(docRef, {'participants': updated});
    });
  }

  Stream<List<Participant>> getParticipantsStream(String splitId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return [];

          final raw = data['participants'] as List<dynamic>? ?? [];
          return raw
              .map((e) => Participant.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        });
  }

  // --------------------------
  // SUMMARY / BALANCES / SETTLEMENTS
  // --------------------------

  // Future<SummaryData> getSummary(String splitId) async {
  //   final splitDoc = await _db
  //       .collection('users')
  //       .doc(_uid)
  //       .collection('splits')
  //       .doc(splitId)
  //       .get();

  //   if (!splitDoc.exists) throw Exception("Split not found");

  //   final split = SplitModel.fromMap(splitDoc.data()!, splitDoc.id);

  //   final expenseDocs = await _db
  //       .collection('users')
  //       .doc(_uid)
  //       .collection('splits')
  //       .doc(splitId)
  //       .collection('expenses')
  //       .orderBy('date', descending: true)
  //       .get();

  //   final expenses = expenseDocs.docs
  //       .map((doc) => Expense.fromMap(doc.data(), doc.id))
  //       .toList();

  //   final balances = calculateBalances(split, expenses);
  //   final settlements = calculateSettlements([...balances]);
  //   final groupedSettlements = calculateGroupedSettlements(expenses);
  //   final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

  //   return SummaryData(
  //     split: split,
  //     expenses: expenses,
  //     balances: balances,
  //     settlements: settlements,
  //     totalExpenses: totalExpenses,
  //     groupedSettlements: groupedSettlements, // ✅ new field
  //   );
  // }

  List<Balance> calculateBalances(SplitModel split, List<Expense> expenses) {
    final balances = <String, Balance>{};

    final allNames = <String>{
      for (var e in expenses) ...e.participants,
      for (var e in expenses) e.paidBy,
    };

    for (var p in split.participants) {
      allNames.add(p.name);
    }

    for (var name in allNames) {
      balances[name] = Balance(person: name);
    }

    for (var e in expenses) {
      balances[e.paidBy]!.totalPaid += e.amount;

      e.shares.forEach((name, amount) {
        balances[name]!.totalOwed += amount;
      });
    }

    for (var b in balances.values) {
      b.netBalance = b.totalPaid - b.totalOwed;
    }

    return balances.values.toList();
  }

  Future<SummaryData> getSummary(String splitId) async {
    // 👇 Always get the freshest version from Firestore
    final split = await getSplit(splitId, forceServer: true);
    final expenses = await getExpensesForSplit(splitId, forceServer: true);

    double totalExpenses = 0;
    final balancesMap = {
      for (var p in split.participants)
        p.name: Balance(
          person: p.name,
          totalPaid: 0,
          totalOwed: 0,
          netBalance: 0,
        ),
    };
    final groupedSettlements = <ExpenseSettlementGroup>[];

    for (var expense in expenses) {
      totalExpenses += expense.amount;

      // --- Record who paid what ---
      if (balancesMap.containsKey(expense.paidBy)) {
        balancesMap[expense.paidBy]!.totalPaid += expense.amount;
      }

      // --- Record each participant’s owed amount ---
      for (var entry in expense.shares.entries) {
        if (balancesMap.containsKey(entry.key)) {
          balancesMap[entry.key]!.totalOwed += entry.value;
        }
      }

      // --- Compute settlements for this expense ---
      final expenseSettlements = _calculateSettlementsForExpense(expense);
      groupedSettlements.add(
        ExpenseSettlementGroup(
          expenseId: expense.id,
          expenseName: expense.description,
          settlements: expenseSettlements,
        ),
      );
    }

    // --- Compute total balances ---
    for (var balance in balancesMap.values) {
      balance.netBalance = balance.totalPaid - balance.totalOwed;
    }

    // --- Global settlements across all expenses ---
    final globalSettlements = _calculateSettlements(
      balancesMap.values.toList(),
    );

    return SummaryData(
      split: split,
      expenses: expenses,
      totalExpenses: totalExpenses,
      balances: balancesMap.values.toList(),
      settlements: globalSettlements,
      groupedSettlements: groupedSettlements,
    );
  }

  Future<void> updateExpense(
    String splitId,
    String expenseId,
    Expense updatedExpense,
  ) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .collection('expenses')
        .doc(expenseId)
        .update(updatedExpense.toMap());
  }

  Future<void> deleteExpense(String splitId, String expenseId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // --- Global settlement calculator (same as before) ---
  List<Settlement> _calculateSettlements(List<Balance> balances) {
    final settlements = <Settlement>[];
    final creditors = balances.where((b) => b.netBalance > 0).toList()
      ..sort((a, b) => b.netBalance.compareTo(a.netBalance));
    final debtors = balances.where((b) => b.netBalance < 0).toList()
      ..sort((a, b) => a.netBalance.compareTo(b.netBalance));

    int i = 0, j = 0;
    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];

      final amount = creditor.netBalance < debtor.netBalance.abs()
          ? creditor.netBalance
          : debtor.netBalance.abs();

      if (amount > 0.01) {
        settlements.add(
          Settlement(from: debtor.person, to: creditor.person, amount: amount),
        );
      }

      creditor.netBalance -= amount;
      debtor.netBalance += amount;

      if (creditor.netBalance < 0.01) i++;
      if (debtor.netBalance.abs() < 0.01) j++;
    }

    return settlements;
  }

  // --- NEW: Per-expense settlement calculator ---
  List<Settlement> _calculateSettlementsForExpense(Expense expense) {
    final settlements = <Settlement>[];

    final balances = expense.shares.entries.map((entry) {
      final person = entry.key;
      final owed = entry.value;
      double paid = person == expense.paidBy ? expense.amount : 0;
      return Balance(
        person: person,
        totalPaid: paid,
        totalOwed: owed,
        netBalance: paid - owed,
      );
    }).toList();

    return _calculateSettlements(balances);
  }

  // List<Settlement> calculateSettlements(List<Balance> balances) {
  //   final settlements = <Settlement>[];
  //   final creditors = balances.where((b) => b.netBalance > 0).toList()
  //     ..sort((a, b) => b.netBalance.compareTo(a.netBalance));
  //   final debtors = balances.where((b) => b.netBalance < 0).toList()
  //     ..sort((a, b) => a.netBalance.compareTo(b.netBalance));

  //   int i = 0, j = 0;
  //   while (i < creditors.length && j < debtors.length) {
  //     final creditor = creditors[i];
  //     final debtor = debtors[j];

  //     final amount = creditor.netBalance < debtor.netBalance.abs()
  //         ? creditor.netBalance
  //         : debtor.netBalance.abs();

  //     if (amount > 0.01) {
  //       settlements.add(
  //         Settlement(from: debtor.person, to: creditor.person, amount: amount),
  //       );
  //     }

  //     creditor.netBalance -= amount;
  //     debtor.netBalance += amount;

  //     if (creditor.netBalance < 0.01) i++;
  //     if (debtor.netBalance.abs() < 0.01) j++;
  //   }

  //   return settlements;
  // }

  Future<SplitModel> getSplit(
    String splitId, {
    bool forceServer = false,
  }) async {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId);

    final snapshot = await docRef.get(
      GetOptions(source: forceServer ? Source.server : Source.serverAndCache),
    );

    if (!snapshot.exists) {
      throw Exception('Split not found');
    }

    return SplitModel.fromMap(snapshot.data()!, snapshot.id);
  }

  /// (Optional) Fetch all expenses under a split
  Future<List<Expense>> getExpensesForSplit(
    String splitId, {
    bool forceServer = false,
  }) async {
    final query = await _db
        .collection('users')
        .doc(_uid)
        .collection('splits')
        .doc(splitId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get(
          GetOptions(
            source: forceServer ? Source.server : Source.serverAndCache,
          ),
        );

    return query.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// 🧾 NEW: Calculate settlements per expense (for grouped summary)
  List<ExpenseSettlementGroup> calculateGroupedSettlements(
    List<Expense> expenses,
  ) {
    const double epsilon = 0.01;
    final grouped = <ExpenseSettlementGroup>[];

    for (final expense in expenses) {
      final participants = expense.participants;
      if (participants.isEmpty) continue;

      final balances = <Balance>[];

      for (final name in participants) {
        final paid = name == expense.paidBy ? expense.amount : 0.0;
        final owed =
            expense.shares[name] ?? (expense.amount / participants.length);
        balances.add(Balance(person: name, totalPaid: paid, totalOwed: owed));
      }

      for (var b in balances) {
        b.netBalance = b.totalPaid - b.totalOwed;
      }

      final settlements = <Settlement>[];
      final creditors = balances.where((b) => b.netBalance > 0).toList()
        ..sort((a, b) => b.netBalance.compareTo(a.netBalance));
      final debtors = balances.where((b) => b.netBalance < 0).toList()
        ..sort((a, b) => a.netBalance.compareTo(b.netBalance));

      int i = 0, j = 0;
      while (i < creditors.length && j < debtors.length) {
        final creditor = creditors[i];
        final debtor = debtors[j];

        final amount = (creditor.netBalance.abs() < debtor.netBalance.abs())
            ? creditor.netBalance.abs()
            : debtor.netBalance.abs();

        if (amount > epsilon) {
          settlements.add(
            Settlement(
              from: debtor.person,
              to: creditor.person,
              amount: amount,
            ),
          );
        }

        creditor.netBalance -= amount;
        debtor.netBalance += amount;

        if (creditor.netBalance.abs() < epsilon) i++;
        if (debtor.netBalance.abs() < epsilon) j++;
      }

      grouped.add(
        ExpenseSettlementGroup(
          expenseId: expense.id,
          expenseName: expense.description,
          settlements: settlements,
        ),
      );
    }

    return grouped;
  }
}
