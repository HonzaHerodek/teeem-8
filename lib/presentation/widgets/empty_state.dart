import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final EdgeInsets padding;
  final CrossAxisAlignment alignment;

  const EmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onActionPressed,
    this.actionLabel,
    this.padding = const EdgeInsets.all(24.0),
    this.alignment = CrossAxisAlignment.center,
  });

  factory EmptyState.noData({
    String? title,
    String? message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return EmptyState(
      title: title ?? 'No Data',
      message: message ?? 'There is no data to display.',
      icon: const Icon(
        Icons.inbox_outlined,
        size: 64,
        color: Colors.grey,
      ),
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
    );
  }

  factory EmptyState.noResults({
    String? title,
    String? message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return EmptyState(
      title: title ?? 'No Results',
      message: message ?? 'No results found for your search.',
      icon: const Icon(
        Icons.search_off,
        size: 64,
        color: Colors.grey,
      ),
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
    );
  }

  factory EmptyState.noPosts({
    String? title,
    String? message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return EmptyState(
      title: title ?? 'No Posts Yet',
      message: message ?? 'Be the first to create a post!',
      icon: const Icon(
        Icons.post_add,
        size: 64,
        color: Colors.grey,
      ),
      onActionPressed: onActionPressed,
      actionLabel: actionLabel ?? 'Create Post',
    );
  }

  factory EmptyState.noNotifications({
    String? title,
    String? message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return EmptyState(
      title: title ?? 'No Notifications',
      message: message ?? 'You\'re all caught up!',
      icon: const Icon(
        Icons.notifications_none,
        size: 64,
        color: Colors.grey,
      ),
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(height: 16),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (message != null) ...[
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          if (onActionPressed != null && actionLabel != null) ...[
            ElevatedButton(
              onPressed: onActionPressed,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateScaffold extends StatelessWidget {
  final String? title;
  final String? emptyTitle;
  final String? emptyMessage;
  final Widget? icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final bool showAppBar;

  const EmptyStateScaffold({
    super.key,
    this.title,
    this.emptyTitle,
    this.emptyMessage,
    this.icon,
    this.onActionPressed,
    this.actionLabel,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title ?? 'No Content'),
            )
          : null,
      body: EmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: icon,
        onActionPressed: onActionPressed,
        actionLabel: actionLabel,
      ),
    );
  }
}

/// Extension method to easily wrap any widget with an empty state
extension EmptyStateExtension on Widget {
  Widget withEmptyState({
    required bool isEmpty,
    String? title,
    String? message,
    Widget? icon,
    VoidCallback? onActionPressed,
    String? actionLabel,
    EdgeInsets padding = const EdgeInsets.all(24.0),
  }) {
    return isEmpty
        ? EmptyState(
            title: title,
            message: message,
            icon: icon,
            onActionPressed: onActionPressed,
            actionLabel: actionLabel,
            padding: padding,
          )
        : this;
  }
}
