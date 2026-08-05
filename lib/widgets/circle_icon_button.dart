import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Small circular icon button used for overlay controls.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: backgroundColor ?? AppConstants.primaryColor.withOpacity(.15),
        ),
        child: Icon(icon, color: iconColor ?? AppConstants.primaryColor),
      ),
    );
  }
}