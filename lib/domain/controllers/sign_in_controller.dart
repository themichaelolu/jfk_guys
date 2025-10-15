import 'package:flutter/widgets.dart';
import 'package:jfk_guys/domain/services/auth_service.dart';
import 'package:jfk_guys/utils/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<dynamic> build() {
    return null;
  }

  Future<dynamic> signIn({
    required String email,
    required password,
    required BuildContext context,
    Function? afterFetched,
  }) async {
    final service = ref.read(authServiceProvider);
    try {
      state = const AsyncValue.loading();
      final login = await service.login(email: email, password: password);
      if (login.toString().contains('Success')) {
        state = AsyncValue.data(login);
        afterFetched?.call();
      } else {
        throw AppException('$login');
      }
    } catch (e, s) {
      state = AsyncError(e, s);
      return null;
    }
    return null;
  }
}
