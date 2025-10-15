import 'dart:async';

import 'package:jfk_guys/domain/models/participant.dart';
import 'package:jfk_guys/domain/providers/firestore_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_participant_controller.g.dart';

@riverpod
class AddParticipantController extends _$AddParticipantController {
  @override
  FutureOr<void> build() => null;

  /// Adds (or replaces) a participant in the given split.
  /// Optionally call [after] when operation completes successfully.
  Future<void> addParticipant({
    required String splitId,
    required Participant participant,
    void Function()? after,
  }) async {
    final service = ref.read(firestoreServiceProvider);

    try {
      state = const AsyncValue.loading();
      await service.addParticipant(splitId, participant);
      state = const AsyncValue.data(null);
      after?.call();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  /// Removes a participant by id from the given split.
  /// Optionally call [after] when operation completes successfully.
  Future<void> removeParticipant({
    required String splitId,
    required String participantId,
    void Function()? after,
  }) async {
    final service = ref.read(firestoreServiceProvider);

    try {
      state = const AsyncValue.loading();
      await service.removeParticipant(splitId, participantId);
      state = const AsyncValue.data(null);
      after?.call();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }
}
