import 'package:flutter/material.dart';

/// The white background used for most of the pages.
///
/// In reality [height] is just an arbitrary number... I don't... really know
/// what it means, just change it until it looks right ¯\_(ツ)_/¯
class PageBackgroundTab extends StatelessWidget {
  final double height;
  const PageBackgroundTab({required this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // This expanded container sticks the white background to the
        // bottom
        Expanded(child: Container()),
        Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          height: MediaQuery.of(context).size.height - 1 - height,
        ),
      ],
    );
  }
}
