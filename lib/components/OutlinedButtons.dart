import 'package:flutter/material.dart';

import '../service/constants.dart';

class OutlinedButtons extends StatelessWidget {
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final Color color;

  const OutlinedButtons({
    super.key,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
    required this.color,
  });


  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      label: Text(
        '${buttonLabel}',
        style: TextStyle(
          color: Constants.mainDarkColor,
        ),
      ),
      icon: Icon(
        buttonIcon,
        color: color,
      ),
      style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          textStyle: TextStyle(
              fontSize: 20
          ),
          minimumSize: Size(170, 40)
      ),
        onPressed: onPressed,
    );
  }
}
