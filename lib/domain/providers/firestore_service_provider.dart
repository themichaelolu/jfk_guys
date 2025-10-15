import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/domain/models/expense_model.dart';
import 'package:jfk_guys/domain/models/participant.dart';
import 'package:jfk_guys/domain/models/split_model.dart';
import 'package:jfk_guys/domain/models/summary_data.dart';
import 'package:jfk_guys/domain/services/firestore_service.dart';

// 1. Provider for the FirestoreService instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// 2. StreamProvider to get the list of all splits
final splitsStreamProvider = StreamProvider<List<SplitModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSplitsStream();
});

// 3. StreamProvider.family to get expenses for a specific SplitModel
final expensesStreamProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  splitId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getExpensesStream(splitId);
});

final summaryProvider = FutureProvider.family<SummaryData, String>((
  ref,
  splitId,
) async {
  final service = ref.read(firestoreServiceProvider);
  return service.getSummary(splitId);
});

final summaryStreamProvider = StreamProvider.family<SummaryData, String>((
  ref,
  splitId,
) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchSummary(splitId);
});

final participantsProvider = StreamProvider.family<List<Participant>, String>((
  ref,
  splitId,
) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getParticipantsStream(splitId);
});

final expensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  splitId,
) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getExpensesStream(splitId);
});
