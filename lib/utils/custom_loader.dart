import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customLoader(Color? color) {
  if (Platform.isIOS) {
    return CupertinoActivityIndicator(
      radius: 16,
      color: color ?? Colors.white, // Available from Flutter 3.7+
    );
  } else {
    return CircularProgressIndicator(
      strokeWidth: 4,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
    );
  }
}
