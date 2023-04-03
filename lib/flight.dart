import 'package:flutter/material.dart';
import 'package:vatsim_tracker/airports.dart' as airports;
import 'dart:math' as math;
import 'flight_plan.dart';

import 'package:vatsim_tracker/pilot.dart';

/// Add "..." to the end of a string if its too long.
///
/// If the length of [str] is less than or equal to [len], str is returned
/// without change. Otherwise, str is cut to be exactly [len] characters long,
/// including the ellipsis at the end.
String setMaxLen(String str, int len) {
  if (str.length <= len) {
    return str;
  }

  str = str.substring(0, len - 3);
  return "$str...";
}

/// Create a general view for a single pilot's flightplan.
class Flight extends StatelessWidget {
  final Pilot pilot;
  final void Function(Pilot) onClick;

  static const TextStyle flightStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "AzeretMono",
  );

  static const double _borderRadius = 20;

  const Flight({required this.pilot, required this.onClick, super.key});

  static const TextStyle dataStyle = TextStyle(
    fontSize: 12,
    color: Colors.white,
    fontFamily: "AzeretMono",
  );

  /// Get the text which should be displayed at the bottom of this widget,
  /// dependent on the flight plan of the pilot.
  String _getDistanceText() {
    FlightPlan? plan = pilot.flightPlan;

    if (plan == null) {
      return "No flightplan filed";
    }

    if (plan.departure == plan.arrival) {
      return "Total distance: 0nm";
    }

    final flightPlanDistance = plan.getDistance().round();
    if (flightPlanDistance <= 0 ||
        plan.arrival == "NONE" ||
        plan.arrival.isEmpty) {
      return "Unknown distance";
    }

    final arrivalAirport = airports.getAirport(plan.arrival);
    final pilotDistance = pilot.getDistanceToAirport(arrivalAirport!).round();
    if (pilot.status == FlightStatus.preflight) {
      return "Total distance: ${flightPlanDistance}nm";
    } else if (pilot.status == FlightStatus.arrived) {
      return "Distance flown: ${flightPlanDistance}nm";
    }
    return "Total distance: ${flightPlanDistance}nm, ${pilotDistance}nm to go";
  }

  Widget _getDepDestPortion() {
    if (pilot.hasFlightPlan) {
      FlightPlan plan = pilot.flightPlan!;
      return Row(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Center(
                child: Text(
                  plan.departure,
                  style: flightStyle,
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: math.pi / 2,
            child: const Icon(
              Icons.airplanemode_active_rounded,
              color: Color.fromARGB(255, 193, 193, 193),
              size: 32,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Center(
                child: Text(
                  plan.arrival,
                  style: flightStyle,
                ),
              ),
            ),
          )
        ],
      );
    }

    return Center(
      child: Text(
        pilot.callsign,
        style: flightStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick(pilot);
      },
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius)),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
          child: Container(
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: _getDepDestPortion(),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Row(
                      children: [
                        Text(
                          pilot.callsign,
                          style: dataStyle,
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Status: ${pilot.status.readable}",
                              style: dataStyle,
                            ),
                          ),
                        ),
                        Text(
                          pilot.flightPlan != null
                              ? pilot.flightPlan!.aircraftShort
                              : "UNKNOWN",
                          style: dataStyle,
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          setMaxLen(pilot.name.trim(), 25).trim(),
                          style: dataStyle,
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "CID: ${pilot.cid}",
                              style: dataStyle,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "ALT: ${pilot.altitude}ft",
                              style: dataStyle,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Align(
                            child: Text(
                              "HDG: ${pilot.heading}°",
                              style: dataStyle,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "GS: ${pilot.groundspeed}kts",
                              style: dataStyle,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Align(
                      child: Text(
                        _getDistanceText(),
                        style: dataStyle,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
