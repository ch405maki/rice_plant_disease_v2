import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Shared primary action button: primary-colour fill, rounded corners and a
/// soft shadow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width = 250,
  }) : super(key: key);

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: AppConstants.primaryColor.withOpacity(.3),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}