import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullPageLoadingWidget extends StatelessWidget{
  const FullPageLoadingWidget({super.key, Color color = Colors.white}) : _color = color;
  final Color  _color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: .infinity,
      width: .infinity,
      color: Colors.black26,
      child: Center(child: Platform.isIOS
          ? CupertinoActivityIndicator(color: _color,)
          : CircularProgressIndicator(color: _color,),),
    );
  }

}