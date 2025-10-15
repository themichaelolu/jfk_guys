import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String paidBy;
  final Map<String, double> shares;
  // Map<participantId, shareAmount>
  final List<String> participants;
  final String? category;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.paidBy,
    required this.shares,
    this.category,
    required this.participants,
  });

  factory Expense.fromMap(Map<String, dynamic> map, String documentId) {
    return Expense(
      id: documentId,
      description: map['description'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      paidBy: map['paidBy'] as String,
      shares: Map<String, double>.from(map['shares']),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'paidBy': paidBy,
      'shares': shares,
      'category': category,
    };
  }
}
