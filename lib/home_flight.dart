import 'package:vatsim_tracker/flight_plan.dart';
import 'package:vatsim_tracker/main.dart';

import 'airports.dart' as airports;
import 'package:flutter/material.dart';
import 'package:vatsim_tracker/progress_circle.dart';
import 'pilot.dart';
import 'flight.dart' show setMaxLen;

/// The widget displayed on the top of the homepage.
class HomeFlight extends StatefulWidget {
  final _HomeFlightState _state;

  /// Display the fligth status for [pilot].
  HomeFlight({required pilot, super.key}) : _state = _HomeFlightState(pilot);

  void setPilot(Pilot pilot) => _state.setPilot(pilot);
  Pilot getPilot() => _state.pilot;

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _state;
}

class _HomeFlightState extends State<HomeFlight> {
  /// The pilot that the homeflight is displaying.
  Pilot pilot;

  static const TextStyle airportTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: "AzeretMono",
    fontSize: 35,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headDataTextStyle = TextStyle(
    color: Colors.white,
    fontFamily: "AzeretMono",
    fontSize: 15,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: "AzeretMono",
    fontSize: 14,
  );

  _HomeFlightState(this.pilot);

  /// Update the pilot.
  void setPilot(Pilot pilot) {
    setState(() {
      this.pilot = pilot;
    });
  }

  /// The text displayed just above the arrival and departure airports regarding
  /// the pilot's distance flown.
  String _getFlightDistanceText() {
    FlightPlan? plan = pilot.flightPlan;

    if (plan == null || plan.arrival == "NONE" || plan.arrival.isEmpty) {
      return "";
    }

    final flightPlanDistance = plan.getDistance().round();
    if (flightPlanDistance < 0) {
      return "Unknown distance";
    }

    final arrivalAirport = airports.getAirport(plan.arrival);
    final pilotDistance = pilot.getDistanceToAirport(arrivalAirport!).round();
    if (pilot.status == FlightStatus.preflight) {
      return "Flown 0nm of ${flightPlanDistance}nm";
    } else if (pilot.status == FlightStatus.arrived) {
      return "Flown ${flightPlanDistance}nm of ${flightPlanDistance}nm";
    }
    return "Flown ${flightPlanDistance - pilotDistance}nm of ${flightPlanDistance}nm";
  }

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
              padding: const EdgeInsets.only(top: 30),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Text(
                      _getFlightDistanceText(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: "AzeretMono",
                        fontSize: 15,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 28),
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
            padding: const EdgeInsets.only(
              top: myFlightHeight / 2 + 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "GS: ${pilot.groundspeed}kts",
                        style: bodyTextStyle,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "HDG: ${pilot.heading}°",
                          style: bodyTextStyle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "ALT: ${pilot.altitude}ft",
                        style: bodyTextStyle,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Lat: ${pilot.latitude}°",
                            style: bodyTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Long: ${pilot.longitude}°",
                            style: bodyTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Squawk: ${pilot.transponder}",
                            style: bodyTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "QNH: ${pilot.qnhIHg}inHg",
                            style: bodyTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
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
