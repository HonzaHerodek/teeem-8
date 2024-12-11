import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class StepTypeUtils {
  static Color getColorForStepType(StepType type) {
    switch (type) {
      case StepType.text:
        return const Color(0xFF4CAF50); // Material Green 500
      case StepType.image:
        return const Color(0xFF2196F3); // Material Blue 500
      case StepType.code:
        return const Color(0xFF9C27B0); // Material Purple 500
      case StepType.video:
        return const Color(0xFFF44336); // Material Red 500
      case StepType.audio:
        return const Color(0xFFFF9800); // Material Orange 500
      case StepType.quiz:
        return const Color(0xFF00BCD4); // Material Cyan 500
      case StepType.ar:
        return const Color(0xFF795548); // Material Brown 500
      case StepType.vr:
        return const Color(0xFF607D8B); // Material Blue Grey 500
      case StepType.document:
        return const Color(0xFF9E9E9E); // Material Grey 500
      case StepType.link:
        return const Color(0xFF3F51B5); // Material Indigo 500
      default:
        return Colors.grey;
    }
  }

  static String getStepTypeDisplayName(StepType type) {
    switch (type) {
      case StepType.text:
        return 'Text';
      case StepType.image:
        return 'Image';
      case StepType.code:
        return 'Code';
      case StepType.video:
        return 'Video';
      case StepType.audio:
        return 'Audio';
      case StepType.quiz:
        return 'Quiz';
      case StepType.ar:
        return 'AR';
      case StepType.vr:
        return 'VR';
      case StepType.document:
        return 'Document';
      case StepType.link:
        return 'Link';
      default:
        return 'Unknown';
    }
  }

  static IconData getIconForStepType(StepType type) {
    switch (type) {
      case StepType.text:
        return Icons.text_fields;
      case StepType.image:
        return Icons.image;
      case StepType.code:
        return Icons.code;
      case StepType.video:
        return Icons.videocam;
      case StepType.audio:
        return Icons.audiotrack;
      case StepType.quiz:
        return Icons.quiz;
      case StepType.ar:
        return Icons.view_in_ar;
      case StepType.vr:
        return Icons.vrpano;
      case StepType.document:
        return Icons.description;
      case StepType.link:
        return Icons.link;
      default:
        return Icons.help_outline;
    }
  }
}
