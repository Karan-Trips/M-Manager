import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum MessageType { info, error, warning, success }

void showMessage(String msg,
    {MessageType type = MessageType.info,
    ToastGravity gravity = ToastGravity.TOP}) {
  Fluttertoast.showToast(
      backgroundColor: type == MessageType.info
          ? Colors.yellow[700]
          : type == MessageType.error
              ? Colors.red
              : Colors.green[300],
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: 3,
      textColor: Colors.white,
      fontSize: 14.0.sp);
}
