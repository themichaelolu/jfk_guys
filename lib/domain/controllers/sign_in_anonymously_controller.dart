import 'package:flutter/material.dart';
import 'package:jfk_guys/domain/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_anonymously_controller.g.dart';

@riverpod
class SignInAnonymouslyController extends _$SignInAnonymouslyController {
  @override
  FutureOr<dynamic> build() {
    return null;
  }

  Future<void> signInAnonymously(VoidCallback? afterFetched) async {
    final service = ref.read(authServiceProvider);
    try {
      state = AsyncValue.loading();
      await service.signInAnonymously();

      afterFetched;
    } catch (e, s) {
      state = AsyncError(e, s);
      // return null;
    }
  }
}
