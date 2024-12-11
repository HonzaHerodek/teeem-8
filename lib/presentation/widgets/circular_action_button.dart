import 'package:flutter/material.dart';

class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isBold;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 56.0;
    const double strokeWidth = 2.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: strokeWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.white,
            size: isBold ? 32.0 : 24.0,
            weight: isBold ? 700 : 400,
          ),
        ),
      ),
    );
  }
}
