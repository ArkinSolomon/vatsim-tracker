import 'airports.dart' as airports;
import 'package:flutter/material.dart';
import 'package:vatsim_tracker/progress_circle.dart';
import 'pilot.dart';

/// The widget displayed on the top of the homepage.
class HomeFlight extends StatelessWidget {
  final Pilot pilot;
  final double _topPadding = 50;
  final double _horizPadding = 50;

  static const TextStyle airportTextStyle = TextStyle(
    color: Colors.white,
    fontFamily: "AzeretMono",
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  /// Display the fligth status for [pilot].
  const HomeFlight({required this.pilot, super.key});

  /// The widget that's displayed if the pilot has an IFR flight plan.
  Widget ifrFlightWidget(BuildContext context) {
    final flightPlan = pilot.flightPlan!;

    double progress;
    if (pilot.status == FlightStatus.arrived) {
      progress = 1;
    } else if (pilot.status == FlightStatus.preflight) {
      progress = 0;
    } else {
      final totalDistance = flightPlan.getDistance();
      if (totalDistance < 0) {
        progress = 0.5;
      } else {
        final distanceTraveled = progress = pilot
            .getDistanceToAirport(airports.getAirport(flightPlan.departure)!);
        progress = distanceTraveled / totalDistance;
      }
    }

    return Container(
      padding: EdgeInsets.only(top: _topPadding),
      child: Stack(
        children: [
          ProgressCircle(
            progress: progress,
            topPadding: _topPadding,
            horizPadding: _horizPadding,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _horizPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        flightPlan.departure,
                        style: airportTextStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        flightPlan.arrival,
                        style: airportTextStyle,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pilot.flightPlan == null) {
      return const Text("TEXT");
    }
    return ifrFlightWidget(context);
  }
}
