import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../core/utils/step_type_utils.dart';

class StepDots extends StatefulWidget {
  final List<PostStep> steps;
  final int currentStep;
  final Function(bool) onHeaderExpandChanged;
  final VoidCallback onTransformToMiniatures;

  const StepDots({
    Key? key,
    required this.steps,
    required this.currentStep,
    required this.onHeaderExpandChanged,
    required this.onTransformToMiniatures,
  }) : super(key: key);

  @override
  State<StepDots> createState() => _StepDotsState();
}

class _StepDotsState extends State<StepDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _offsetAnimation;
  late Animation<double> _spacingAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<double>(
      begin: 0.0,
      end: -8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _spacingAnimation = Tween<double>(
      begin: 32.0, // Wide spacing
      end: 24.0,   // Narrow spacing
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial animation state based on current step
    if (_isFirstOrLastStep) {
      _animationController.value = 0.0; // Wide spacing
    } else {
      _animationController.value = 1.0; // Narrow spacing
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCurrentStep(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StepDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      if (_isFirstOrLastStep) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      _centerCurrentStep(animate: true);
    }
  }

  void _centerCurrentStep({required bool animate}) {
    if (!_scrollController.hasClients) return;

    final itemWidth = _spacingAnimation.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final totalContentWidth = widget.steps.length * itemWidth;
    
    if (totalContentWidth <= screenWidth) {
      // If content fits the screen, center all dots
      if (animate) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
      return;
    }

    // If content doesn't fit, center current step
    final visibleItems = (screenWidth / itemWidth).floor();
    final halfVisibleItems = visibleItems ~/ 2;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final itemPosition = widget.currentStep;
    
    final idealOffset = (itemPosition - halfVisibleItems) * itemWidth;
    final offset = idealOffset.clamp(0.0, maxScroll);

    if (animate) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }

  bool get _isFirstOrLastStep =>
      widget.currentStep == 0 || widget.currentStep == widget.steps.length - 1;

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isFirstOrLastStep && details.delta.dy > 0) {
      widget.onHeaderExpandChanged(true);
    }
  }

  void _handleDotTap(int index) {
    if (index != 0 && index != widget.steps.length - 1) {
      widget.onTransformToMiniatures();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final itemWidth = _spacingAnimation.value;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          transform: Matrix4.translationValues(0, _offsetAnimation.value, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final totalContentWidth = widget.steps.length * itemWidth;
              final sidePadding = totalContentWidth <= screenWidth
                  ? (screenWidth - totalContentWidth) / 2  // Center when all dots fit
                  : _isFirstOrLastStep 
                      ? 128.0  // Extra large padding for first/last step
                      : 96.0;  // Large padding for other cases

              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.steps.length,
                      (index) {
                        final color = StepTypeUtils.getColorForStepType(
                            widget.steps[index].type);
                        return GestureDetector(
                          onTap: () => _handleDotTap(index),
                          onVerticalDragUpdate: _isFirstOrLastStep
                              ? _handleVerticalDragUpdate
                              : null,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: itemWidth,
                            height: 32.0,
                            alignment: Alignment.center,
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == widget.currentStep
                                    ? color
                                    : color.withOpacity(0.3),
                                border: Border.all(
                                  color: color.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class StepMiniatures extends StatefulWidget {
  final List<PostStep> steps;
  final int currentStep;
  final Function(bool) onHeaderExpandChanged;
  final VoidCallback? onTransformToDots;
  final PageController pageController;

  const StepMiniatures({
    Key? key,
    required this.steps,
    required this.currentStep,
    required this.onHeaderExpandChanged,
    required this.pageController,
    this.onTransformToDots,
  }) : super(key: key);

  @override
  State<StepMiniatures> createState() => _StepMiniaturesState();
}

class _StepMiniaturesState extends State<StepMiniatures> {
  late ScrollController _scrollController;
  bool _isInExpandedHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _isInExpandedHeader = widget.onTransformToDots == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCurrentStep(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StepMiniatures oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _centerCurrentStep(animate: true);
    }
  }

  void _centerCurrentStep({required bool animate}) {
    if (!_scrollController.hasClients) return;

    final itemWidth = 68.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final totalContentWidth = widget.steps.length * itemWidth;

    if (totalContentWidth <= screenWidth) {
      // If content fits the screen, center all miniatures
      if (animate) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
      return;
    }

    // Always center the current step, regardless of expanded header state
    final visibleItems = (screenWidth / itemWidth).floor();
    final halfVisibleItems = visibleItems ~/ 2;
    final targetOffset = (widget.currentStep - halfVisibleItems) * itemWidth;

    // Clamp the offset to valid range
    final offset =
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    if (animate) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }

  void _handleStepTap(int index) {
    if (index == widget.currentStep && !_isInExpandedHeader) {
      widget.onTransformToDots?.call();
      return;
    }

    if (_isInExpandedHeader) {
      widget.onHeaderExpandChanged(false);
    }

    widget.pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = 68.0;
          final screenWidth = constraints.maxWidth;
          final totalContentWidth = widget.steps.length * itemWidth;
          final sidePadding = totalContentWidth <= screenWidth
              ? (screenWidth - totalContentWidth) / 2
              : itemWidth / 2;

          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.steps.length,
                  (index) {
                    final color = StepTypeUtils.getColorForStepType(
                        widget.steps[index].type);
                    final icon = StepTypeUtils.getIconForStepType(
                        widget.steps[index].type);
                    return InkWell(
                      onTap: () => _handleStepTap(index),
                      child: Container(
                        width: itemWidth,
                        height: 68.0,
                        alignment: Alignment.center,
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(
                              color: index == widget.currentStep
                                  ? color
                                  : color.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icon,
                                  color: index == widget.currentStep
                                      ? color
                                      : color.withOpacity(0.7),
                                  size: 20,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: index == widget.currentStep
                                        ? color
                                        : color.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
