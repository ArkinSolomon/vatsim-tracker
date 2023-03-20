import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main.dart' show myFlightHeight, lerp;
import 'dart:math' as math;

class ProgressCircle extends StatelessWidget {
  final double topPadding;
  final double horizPadding;
  final double _progress;
  final Widget _circleSvg = SvgPicture.asset("assets/progress_circle.svg");

  final double _flightIconSize = 40;
  final double _progressCircleThickness = 18;

  ProgressCircle({
    required double progress,
    required this.topPadding,
    required this.horizPadding,
    super.key,
  }) : _progress = progress.clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final usableHeight = myFlightHeight - topPadding;
    final usableWidth = MediaQuery.of(context).size.width - horizPadding * 2;

    final angle = lerp(0, math.pi, _progress);
    final centerY = usableHeight / 2 - _flightIconSize / 2;
    final centerX = horizPadding + usableWidth / 2 - _flightIconSize / 2;
    final radius = usableHeight / 2 - _progressCircleThickness / 2;

    final planeTop = centerY - radius * math.sin(angle);
    final planeLeft = centerX + radius * math.cos(math.pi - angle);

    return SizedBox(
      height: usableHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRect(
            clipper: _ProgressCircleClipper(topPadding),
            child: Transform.rotate(
              angle: angle + 0.005,
              child: _circleSvg,
            ),
          ),
          Positioned(
            top: planeTop,
            left: planeLeft,
            child: Transform.rotate(
              angle: angle,
              child: Image(
                height: _flightIconSize,
                width: _flightIconSize,
                image: const AssetImage(
                    "assets/placeholder_progress_aircraft.png"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ProgressCircleClipper extends CustomClipper<Rect> {
  final double _topPadding;

  _ProgressCircleClipper(topPadding) : _topPadding = topPadding;

  @override
  Rect getClip(Size size) {
    // Use a large number instead of infinity, infinity doesn't work
    return Rect.fromLTWH(0, 0, 1000000, (myFlightHeight - _topPadding) / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
