import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double tabletBreakpoint = 600;
  static const double contentMaxWidth = 720;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  static Widget constrainContent({
    required BuildContext context,
    required Widget child,
  }) {
    if (!isTablet(context)) return child;
    return Align(
      alignment: .topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: contentMaxWidth),
        child: child,
      ),
    );
  }
}
