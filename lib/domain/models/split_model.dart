import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jfk_guys/domain/models/expense_model.dart';
import 'package:jfk_guys/domain/models/participant.dart';

class SplitModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Participant> participants;

  SplitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.participants,
  });

  factory SplitModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SplitModel(
      id: documentId,
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: (map['participants'] as List? ?? [])
          .map((p) => Participant.fromMap(p))
          .toList(),
    );
  }

  Map<String, dynamic> toMap({bool forCreate = false}) {
    return {
      'name': name,
      'createdAt': forCreate
          ? FieldValue.serverTimestamp() // 👈 use server time when creating a new split
          : Timestamp.fromDate(createdAt),
      'participants': participants.map((p) => p.toMap()).toList(),
    };
  }
}
