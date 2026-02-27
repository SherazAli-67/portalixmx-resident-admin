import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatefulWidget {
  final Widget? child;
  final Widget Function(ScrollController scrollController, ScrollPhysics scrollPhysics)? scrollableBuilder;
  final double minHeight;
  final double maxHeight;
  final double? initialHeight;
  final VoidCallback? onDismiss;

  const DraggableBottomSheet({
    super.key,
    this.child,
    this.scrollableBuilder,
    this.minHeight = 0.3,
    this.maxHeight = 0.9,
    this.initialHeight,
    this.onDismiss,
  }) : assert(child != null || scrollableBuilder != null, 'Provide either child or scrollableBuilder'),
       assert(child == null || scrollableBuilder == null, 'Provide only one of child or scrollableBuilder');

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<double>? _heightAnimation;
  ScrollController? _scrollController;

  double _currentHeight = 0.5; // Start at 50% as default
  double _dragStartHeight = 0.0;
  double _dragStartPosition = 0.0;
  bool _isDragging = false;
  final GlobalKey _contentKey = GlobalKey();

  final List<double> _snapPoints = [0.3, 0.5, 0.7, 0.9];

  static const double _maxHeightThreshold = 0.05; // Within 5% of max = "at max"

  bool get _useScrollableBuilder => widget.scrollableBuilder != null;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.initialHeight ?? 0.5;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (_useScrollableBuilder) {
      _scrollController = ScrollController();
    }
    if (!_useScrollableBuilder) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureInitialHeight());
    }
  }

  void _measureInitialHeight() {
    if (widget.initialHeight != null) return;
    final RenderBox? renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final screenHeight = MediaQuery.of(context).size.height;
      final contentHeight = renderBox.size.height + 24; // Add padding for drag handle
      final initialHeight = (contentHeight / screenHeight).clamp(widget.minHeight, widget.maxHeight);

      setState(() => _currentHeight = initialHeight);
    }
  }
  
  bool get _isAtMaxHeight {
    return (_currentHeight >= widget.maxHeight - _maxHeightThreshold);
  }
  
  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartHeight = _currentHeight;
      _dragStartPosition = details.globalPosition.dy;
    });
    _animationController.stop();
  }
  
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final dragDelta = (_dragStartPosition - details.globalPosition.dy) / screenHeight;
    final newHeight = (_dragStartHeight + dragDelta).clamp(widget.minHeight, widget.maxHeight);
    
    setState(()=> _currentHeight = newHeight);
  }
  
  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    setState(() => _isDragging = false);
    
    final screenHeight = MediaQuery.of(context).size.height;
    final velocity = -details.velocity.pixelsPerSecond.dy / screenHeight;
    
    if (_currentHeight <= widget.minHeight + 0.05 || velocity > 0.5) {
      _dismissSheet();
      return;
    }
    
    _snapToNearestPoint();
  }
  
  void _snapToNearestPoint() {
    double nearestSnap = _snapPoints[0];
    double minDistance = (_currentHeight - _snapPoints[0]).abs();
    
    for (final snap in _snapPoints) {
      final distance = (_currentHeight - snap).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearestSnap = snap;
      }
    }
    
    _animateToHeight(nearestSnap);
  }
  
  void _animateToHeight(double targetHeight) {
    _heightAnimation = Tween<double>(
      begin: _currentHeight,
      end: targetHeight,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut,));
    
    _heightAnimation!.addListener(() {
      if (mounted) {
        setState(()=>  _currentHeight = _heightAnimation!.value);
      }
    });
    
    _animationController.forward(from: 0.0).then((_) {
      if (mounted) {
        _animationController.reset();
      }
    });
  }
  
  void _dismissSheet() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).pop({'isEdit': false, 'isDelete': false});
    }
  }
  
  ScrollPhysics get _scrollPhysics =>
      _isAtMaxHeight ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics();

  @override
  void dispose() {
    _scrollController?.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentSheetHeight = _currentHeight * screenHeight;
    
    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Container(
        height: currentSheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const .only(
            topLeft: .circular(32),
            topRight: .circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
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
              child: _useScrollableBuilder
                  ? widget.scrollableBuilder!(_scrollController!, _scrollPhysics)
                  : SingleChildScrollView(
                      key: _contentKey,
                      physics: _scrollPhysics,
                      child: widget.child!,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

