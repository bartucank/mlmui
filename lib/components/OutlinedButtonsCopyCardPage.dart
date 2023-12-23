import 'package:flutter/material.dart';

class OutlinedButtonsCopyCardPage extends StatelessWidget {
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  const OutlinedButtonsCopyCardPage({
    super.key,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
    required this.color,
    required this.textColor
  });


  @override
  Widget build(BuildContext context) {
    String label = buttonLabel.length <= 22 ? buttonLabel : buttonLabel.substring(0, 22);

    return OutlinedButton.icon(
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
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
        minimumSize: Size(250, 40),
      ),
      onPressed: onPressed,
    );
  }

}
