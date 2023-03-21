import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main.dart' show myFlightHeight, lerp;
import 'dart:math' as math;

/// The circle and airplane used to show progress for a flight.
///
/// Note that this widget is currently only designed to work with [HomeFlight].
class ProgressCircle extends StatelessWidget {
  /// The padding at the top of the wrapping widget.
  final double topPadding;

  /// The padding at the left and right of the widget.
  ///
  /// This assumes that the left and right of the widget has symmetrical
  /// padding.
  final double horizPadding;
  final double _progress;
  final Widget _circleSvg = SvgPicture.asset("assets/progress_circle.svg");

  /// The size of the square icon that is the plane at the front of the circle.
  static const double _flightIconSize = 40;

  /// How thick the stroke of the circle is.
  ///
  /// There is no particular measurment unit, just guess and adjust it until the
  /// plane looks centered enough.
  static const double _progressCircleThickness = 18;

  /// Create a new progress circle with a progress of [progress] * 100%.
  ///
  /// [progress] should be a number between zero and one, and will be clamped if
  /// to such bounds.
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
              child: const Image(
                height: _flightIconSize,
                width: _flightIconSize,
                image: AssetImage("assets/placeholder_progress_aircraft.png"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// This clipper clips the progress circle to half of the height of the wrapping
/// widget (taking padding into account).
///
/// This also depends on [myFlightHeight], which is defined in the `main.dart`
/// file.
class _ProgressCircleClipper extends CustomClipper<Rect> {
  final double _topPadding;

  /// Create a new clipper, where [topPadding] is the padding above the circle.
  ///
  /// Should be the same as defined at instantiation of the calling instance of
  /// [ProgressCircle].
  _ProgressCircleClipper(topPadding) : _topPadding = topPadding;

  @override
  Rect getClip(Size size) {
    // Use a large number instead of infinity, infinity doesn't work
    return Rect.fromLTWH(0, 0, 1000000, (myFlightHeight - _topPadding) / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
