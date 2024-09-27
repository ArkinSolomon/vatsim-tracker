import 'package:flutter/material.dart';

class DrawerButton extends StatelessWidget {
  final void Function() onClick;
  final String text;

  const DrawerButton({required this.text, required this.onClick, super.key});

  static const TextStyle _textStyle = TextStyle(
    fontFamily: "AzeretMono",
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onClick,
        // Stacking 2 containers on top of each other lets us get the shortened
        // border while still allowing the splash effect to stretch beyond it
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: _textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
