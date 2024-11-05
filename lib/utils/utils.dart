import 'package:flutter/material.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:try1/utils/gfgtoast.dart';

void showMessageTop(
  BuildContext context,
  String msg, {
  Color bgColor = Colors.white,
  Color textColor = Colors.red,
}) {
  GFToast.showToast(msg, context,
      toastPosition: GFToastPosition.TOP,
      textStyle: TextStyle(fontSize: 16, color: textColor),
      backgroundColor: bgColor,
      trailing: null);
}
