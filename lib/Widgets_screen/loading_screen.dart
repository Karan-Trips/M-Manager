// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatefulWidget {
  final bool status;
  final Widget child;
  final bool backgroundTransparent;
  final String? message;

  const Loading({
    required this.status,
    required this.child,
    this.backgroundTransparent = false,
    this.message,
    super.key,
  });

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[widget.child, _loading(widget.status)]);
  }

  Widget _loading(bool loading) {
    return loading == true
        ? Container(
            height: 1.sh,
            width: 1.sw,
            alignment: Alignment.center,
            color: widget.backgroundTransparent == true
                ? Colors.grey
                : Colors.grey.withOpacity(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset('images/loading.json'),
              ],
            ),
          )
        : Container();
  }
}
