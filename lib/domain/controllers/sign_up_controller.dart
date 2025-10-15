import 'package:jfk_guys/domain/services/auth_service.dart';
import 'package:jfk_guys/utils/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_up_controller.g.dart';

@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<void> build() {}

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    Function? afterFetched,
  }) async {
    final service = ref.read(authServiceProvider);
    try {
      state = const AsyncLoading();

      final currentUser = service.currentUser;

      String? result;
      if (currentUser != null && currentUser.isAnonymous) {
        // Upgrade anonymous user
        result = await service.upgradeAnonymousAccount(
          email: email,
          password: password,
          name: name,
        );
      } else {
        // Normal signup
        result = await service.signUp(email: email, password: password);
      }

      if (result!.contains("Success")) {
        state = AsyncData(result);
        afterFetched?.call();
      } else {
        throw AppException(result);
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}
