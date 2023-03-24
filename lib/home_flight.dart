import 'airports.dart' as airports;
import 'package:flutter/material.dart';
import 'package:vatsim_tracker/progress_circle.dart';
import 'pilot.dart';
import 'flight.dart' show setMaxLen;

/// The widget displayed on the top of the homepage.
class HomeFlight extends StatelessWidget {
  final Pilot pilot;

  static const TextStyle airportTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: "AzeretMono",
    fontSize: 35,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headDataTextStyle = TextStyle(
    color: Colors.white,
    fontFamily: "AzeretMono",
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
        final distanceTraveled = pilot
            .getDistanceToAirport(airports.getAirport(flightPlan.departure)!);

        if (distanceTraveled > totalDistance * 1.15 ||
            pilot.status == FlightStatus.unknown) {
          progress = 0.5;
        } else {
          progress = distanceTraveled / totalDistance;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.only(top: 65),
      child: Stack(
        children: [
          ProgressCircle(
            progress: progress,
            padding: 100,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.only(top: 34),
              child: Column(
                children: [
                  Text(pilot.callsign, style: headDataTextStyle),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(flightPlan.aircraftShort,
                        style: headDataTextStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text("Status: ${pilot.status.readable}",
                        style: headDataTextStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(setMaxLen(pilot.name, 24),
                        style: headDataTextStyle),
                  )
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 34),
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
          ),
          Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.pink, width: 1)),
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
