import 'package:flutter/material.dart';

/// Small spinner shown inside a button while its action is running.
/// Takes the button's text colour, so it works on filled and outlined buttons.
class ButtonLoadingIndicator extends StatelessWidget {
  const ButtonLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: DefaultTextStyle.of(context).style.color,
      ),
    );
  }
}
