import 'package:flutter/material.dart';
import '../../data/models/post_model.dart' show PostStep, StepType;

class StepCarousel extends StatefulWidget {
  final List<PostStep> steps;
  final bool showArrows;
  final Function(int)? onPageChanged;

  const StepCarousel({
    super.key,
    required this.steps,
    this.showArrows = false,
    this.onPageChanged,
  });

  @override
  State<StepCarousel> createState() => _StepCarouselState();
}

class _StepCarouselState extends State<StepCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildScrollableContent(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipOval(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(PostStep step) {
    switch (step.type) {
      case StepType.text:
        return _buildScrollableContent(
          Text(
            step.getContentValueAsString('text') ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        );
      case StepType.image:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                step.getContentValueAsString('imageUrl') ?? '',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                  );
                },
              ),
              if (step.getContentValueAsString('caption') != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    step.getContentValueAsString('caption')!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      case StepType.video:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 48,
              ),
              if (step.getContentValueAsString('description') != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    step.getContentValueAsString('description')!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      case StepType.audio:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.audiotrack,
                color: Colors.white,
                size: 48,
              ),
              if (step.getContentValueAsString('description') != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    step.getContentValueAsString('description')!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      case StepType.quiz:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                step.getContentValueAsString('question') ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...(step.getContentValue('options') as List<dynamic>? ?? [])
                  .map((option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          option.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ))
                  .toList(),
            ],
          ),
        );
      case StepType.code:
        return _buildScrollableContent(
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step.getContentValueAsString('language') != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      step.getContentValueAsString('language')!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Text(
                  step.getContentValueAsString('code') ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      case StepType.ar:
      case StepType.vr:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                step.type == StepType.ar ? Icons.view_in_ar : Icons.vrpano,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Launch ${step.type == StepType.ar ? 'AR' : 'VR'} Experience',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (step.getContentValueAsString('instructions') != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    step.getContentValueAsString('instructions')!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      case StepType.document:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              if (step.getContentValueAsString('summary') != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    step.getContentValueAsString('summary')!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      case StepType.link:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.link,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              if (step.getContentValueAsString('description') != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    step.getContentValueAsString('description')!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      default:
        return const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.steps.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            widget.onPageChanged?.call(index);
          },
          itemBuilder: (context, index) {
            final step = widget.steps[index];
            return _buildStepContent(step);
          },
        ),
        if (widget.showArrows && widget.steps.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _currentPage > 0
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : const SizedBox(width: 48),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _currentPage < widget.steps.length - 1
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : const SizedBox(width: 48),
            ),
          ),
        ],
      ],
    );
  }
}
