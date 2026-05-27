import 'package:flutter/material.dart';

/// A one-shot scrolling visibility reveal animator.
/// Fades in and slides up a widget when it is scrolled 20% into the viewport.
/// Respects system reduced-motion preferences.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final double triggerPercentage;
  final Duration duration;
  final double slideOffset;

  const ScrollReveal({
    super.key,
    required this.child,
    this.triggerPercentage = 0.20,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = 16.0,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _slideAnimation;
  bool _hasAnimated = false;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // settle rather than snap
      ),
    );

    _slideAnimation = Tween<double>(begin: widget.slideOffset, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      _hasAnimated = true;
      _controller.value = 1.0;
      _cleanupScroll();
      return;
    }

    if (!_hasAnimated) {
      _subscribeToScroll();
    }
  }

  void _subscribeToScroll() {
    _cleanupScroll();
    try {
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null) {
        _scrollPosition = scrollable.position;
        _scrollPosition?.addListener(_checkReveal);
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkReveal());
      }
    } catch (_) {}
  }

  void _cleanupScroll() {
    _scrollPosition?.removeListener(_checkReveal);
    _scrollPosition = null;
  }

  void _checkReveal() {
    if (_hasAnimated || !mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    try {
      final position = renderBox.localToGlobal(Offset.zero);
      final viewportHeight = _scrollPosition?.viewportDimension ?? MediaQuery.sizeOf(context).height;

      // Trigger when top edge crosses ~20% up from the bottom of the viewport
      final triggerLimit = viewportHeight * (1.0 - widget.triggerPercentage);

      if (position.dy <= triggerLimit) {
        setState(() {
          _hasAnimated = true;
        });
        _controller.forward();
        _cleanupScroll();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cleanupScroll();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAnimated && _controller.value == 1.0) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
