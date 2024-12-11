import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.progressColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (backgroundColor ?? Colors.black).withOpacity(opacity),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressColor ?? theme.colorScheme.primary,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension method to easily wrap any widget with a loading overlay
extension LoadingOverlayExtension on Widget {
  Widget withLoadingOverlay({
    required bool isLoading,
    String? message,
    Color? backgroundColor,
    Color? progressColor,
    double opacity = 0.7,
  }) {
    return LoadingOverlay(
      isLoading: isLoading,
      message: message,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      opacity: opacity,
      child: this,
    );
  }
}

/// A widget that shows a loading indicator in the center of the screen
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? theme.colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A widget that shows a loading indicator with a scaffold
class LoadingScaffold extends StatelessWidget {
  final String? title;
  final String? message;
  final Color? color;

  const LoadingScaffold({
    super.key,
    this.title,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
            )
          : null,
      body: LoadingIndicator(
        message: message,
        color: color,
      ),
    );
  }
}
