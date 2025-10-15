// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/utils/alert_dialog_ui.dart';
import 'package:jfk_guys/utils/app_exception.dart';

extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(
    BuildContext context, {
    dynamic okAction,
    dynamic cancelAction,
  }) {
    if (!isLoading && hasError) {
      showExceptionAlertDialog(
        context: context,
        title: 'Error',
        exception: checkMessageIsString(error),
        okAction: okAction ?? () {},
        cancelAction: cancelAction ?? () {},
      );
    }
  }

  void showAlertDialogOnSuccess(
    BuildContext context, {
    dynamic okAction,
    dynamic cancelAction,
    required String content,
    String? cancelActionText,
  }) {
    if (!isRefreshing && hasValue) {
      showAlertDialog(
        context: context,
        title: 'Success',
        content: content,
        cancelActionText: cancelActionText,
        okAction: okAction,
      );
    }
  }

  String? checkMessageIsString(dynamic errorMsg) {
    if (errorMsg.runtimeType == String) {
      return errorMsg;
    } else if (errorMsg.runtimeType == AppException) {
      return errorMsg.message ?? 'We are unable to process request, try again';
    } else {
      return 'Something went wrong processinng  request';
    }
  }
}
