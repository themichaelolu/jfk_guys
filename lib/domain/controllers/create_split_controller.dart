import 'package:jfk_guys/domain/models/split_model.dart';
import 'package:jfk_guys/domain/providers/firestore_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_split_controller.g.dart';

@riverpod
class CreateSplitController extends _$CreateSplitController {
  @override
  FutureOr<SplitModel?> build() => null;

  Future<void> createSplit({
    required String name,
    Function(SplitModel)? afterFetched,
  }) async {
    final service = ref.read(firestoreServiceProvider);

    try {
      state = const AsyncValue.loading();

      final split = await service.createSplit(name);

      state = AsyncValue.data(split);

      // Callback with the created split model
      afterFetched?.call(split);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }
}
