import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppUtils {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }

  // Username validation
  static bool isValidUsername(String username) {
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegExp.hasMatch(username) &&
        username.length >= AppConstants.minUsernameLength &&
        username.length <= AppConstants.maxUsernameLength;
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }

  // File size validation
  static bool isValidFileSize(File file, int maxSize) {
    return file.lengthSync() <= maxSize;
  }

  // Date formatting
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Generate unique ID
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Check if URL is valid
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (_) {
      return false;
    }
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Check if file is image
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  // Check if file is video
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final names = name.trim().split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  // Get platform
  static String getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}

// Extension methods
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get initials => AppUtils.getInitials(this);
}

extension DateTimeExtension on DateTime {
  String get formatted => AppUtils.formatDate(this);
}

extension BuildContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    AppUtils.showSnackBar(this, message, isError: isError);
  }

  void showLoading() {
    AppUtils.showLoadingDialog(this);
  }

  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return AppUtils.showConfirmationDialog(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
