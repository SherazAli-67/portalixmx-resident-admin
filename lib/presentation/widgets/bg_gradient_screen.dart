import 'package:flutter/material.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_icons.dart';

class BgGradientScreen extends StatelessWidget{
  const BgGradientScreen({super.key, required  this.
  child, this.paddingFromTop, this.floatingActionButton});
  final Widget child;
  final double? paddingFromTop;
  final FloatingActionButton? floatingActionButton;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height*0.7,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.btnColor,
                        AppColors.btnColor.withValues(alpha: 0.0)
                      ])
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 50,
            child: Image.asset(AppIcons.icScreenBg, height: 150,),
          ),
          paddingFromTop != null ? Padding(padding: EdgeInsets.only(top: paddingFromTop!), child: child,) : child
        ],
      ),
    );
  }

}