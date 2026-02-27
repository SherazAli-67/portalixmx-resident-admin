import 'package:flutter/material.dart';
import '../../../presentation/screens/main_menu/main_menu.dart';
import '../../presentation/widgets/draggable_bottom_sheet.dart';

class _DraggableBottomSheetRoute<T> extends PageRouteBuilder<T> {
  _DraggableBottomSheetRoute({
    required Widget sheet,
  }) : super(
          opaque: false,
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop<T>(null),
                      child: Container(color: Colors.black54),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: sheet,
                    ),
                  ),
                ],
              ),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeIn,
                )),
                child: child,
              ),
            );
          },
        );
}

class BottomSheetHelper {
  static Future<T?> showDraggableBottomSheet<T>({
    required GlobalKey<ScaffoldState> scaffoldKey,
    required Widget child,
    double minHeight = 0.3,
    double maxHeight = 0.9,
    double? initialHeight,
  }) async {
    final ctx = scaffoldKey.currentContext;
    if (ctx == null) return null;
    return Navigator.of(ctx).push<T>(
      _DraggableBottomSheetRoute<T>(
        sheet: DraggableBottomSheet(
          minHeight: minHeight,
          maxHeight: maxHeight,
          initialHeight: initialHeight,
          onDismiss: () => Navigator.of(ctx).pop<T>(null),
          child: child,
        ),
      ),
    );
  }

  static Future<T?> showDraggableListBottomSheet<T>({
    required GlobalKey<ScaffoldState> scaffoldKey,
    required Widget Function(ScrollController scrollController, ScrollPhysics scrollPhysics) contentBuilder,
    double minHeight = 0.3,
    double maxHeight = 0.9,
    double? initialHeight,
  }) async {
    final ctx = scaffoldKey.currentContext;
    if (ctx == null) return null;
    return Navigator.of(ctx).push<T>(
      _DraggableBottomSheetRoute<T>(
        sheet: DraggableBottomSheet(
          minHeight: minHeight,
          maxHeight: maxHeight,
          initialHeight: initialHeight,
          onDismiss: () => Navigator.of(ctx).pop<T>(null),
          scrollableBuilder: contentBuilder,
        ),
      ),
    );
  }


  static Future<T?> showAdjustableModalBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    double initialChildSize = 0.5,
    double minChildSize = 0.3,
    double maxChildSize = 0.95,
    bool showDragHandle = true,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      backgroundColor: Colors.transparent,
      shape: shape,
      builder: (context) => Padding(
        padding:  .only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: const .only(
                  topLeft: .circular(32),
                  topRight: .circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: .min,
                children: [
                  if (showDragHandle)
                    Container(
                      margin: const .only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: .circular(2),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: child,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static void listViewDraggableBottomSheet(Widget child){
    scaffoldKey.currentState!.showBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      enableDrag: false,
      sheetAnimationStyle: const AnimationStyle(duration: Duration(milliseconds: 500), reverseDuration: Duration(milliseconds: 300),),
      shape: const RoundedRectangleBorder(borderRadius: .only(topLeft: .circular(32), topRight: .circular(32),),), (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx, {'isEdit': false, 'isDelete': false}),
              child: Container(color: Colors.black54),
            ),
          ),
          Align(
            alignment: .bottomCenter,
            child: Padding(
              padding:  .only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                builder: (BuildContext context, ScrollController scrollController) => child,
              ),
            )
          ),
        ],
      ),
    ),
    );
  }
}