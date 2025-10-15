// ignore_for_file: public_member_api_docs

import 'package:another_flushbar/flushbar.dart';

import 'package:flutter/material.dart';
import 'package:jfk_guys/constants/app_colors.dart';

const kDialogDefaultKey = Key('dialog-default-key');

final nairaSign = '\u20A6';

/// Generic function to show a platform-aware Material or Cupertino dialog
Future<bool?> showAlertDialog({
  required BuildContext context,
  required String title,
  String? content,
  String? cancelActionText,
  String defaultActionText = 'OK',
  dynamic okAction,
  bool? barrierDismissible,
  dynamic cancelAction,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible ?? true,
    // cancelActionText != null,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: content != null ? Text(content) : null,
      actions: <Widget>[
        if (cancelActionText != null)
          TextButton(
            child: Text(cancelActionText),
            onPressed: () {
              Navigator.of(context).pop(false);
              cancelAction();
            },
          ),
        TextButton(
          key: kDialogDefaultKey,
          child: Text(defaultActionText),
          onPressed: () {
            Navigator.of(context).pop(false);
            okAction();
          },
        ),
      ],
    ),
  );
}

Future<void> showCheckFlash(
  BuildContext context,
  String text, {
  bool showAction = false,
  bool showIcon = false,
  Color? backGroundColor,
  VoidCallback? onOk,
}) {
  return Flushbar(
    margin: const EdgeInsets.all(8),
    duration: const Duration(seconds: 2),
    borderRadius: BorderRadius.circular(8),
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: AppColors.primaryColor.withAlpha(30),
    message: text,
  ).show(context);
}

/// Generic function to show a platform-aware Material or Cupertino error dialog
Future<void> showExceptionAlertDialog({
  required BuildContext context,
  required String title,
  required dynamic exception,
  dynamic okAction,
  dynamic cancelAction,
}) => showAlertDialog(
  context: context,
  title: title,
  content: exception.toString(),
  okAction: okAction,
  cancelAction: cancelAction,
);

Future<void> showNotImplementedAlertDialog({required BuildContext context}) =>
    showAlertDialog(context: context, title: 'Not implemented');
