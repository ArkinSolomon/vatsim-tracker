import 'package:flutter/material.dart';
import 'package:vatsim_tracker/airports.dart' as airports;
import 'dart:math' as math;
import 'flight_plan.dart' show FlightPlan, calculateDistance;

import 'package:vatsim_tracker/pilot.dart';

String setMaxLen(String str, int len) {
  if (str.length <= len) {
    return str;
  }

  str = str.substring(0, len - 3);
  return "$str...";
}

class Flight extends StatelessWidget {
  const Flight(this.pilot, {super.key});

  final Pilot pilot;

  final TextStyle flightStyle = const TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: "AzeretMono",
  );

  final TextStyle dataStyle = const TextStyle(
    fontSize: 12,
    color: Colors.white,
    fontFamily: "AzeretMono",
  );

  String getDistanceText() {
    FlightPlan? plan = pilot.flightPlan;

    if (plan == null || plan.arrival == "NONE" || plan.arrival.isEmpty) {
      return "";
    }

    if (plan.departure == plan.arrival) {
      return "Total distance: 0nm";
    }

    final flightPlanDistance = plan.getDistance().round();
    if (flightPlanDistance < 0) {
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

  @override
  Widget build(BuildContext context) {
    if (pilot.flightPlan != null) {
      return GestureDetector(
        onTap: () {
          print("${pilot.latitude}, ${pilot.longitude}");
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromRGBO(235, 222, 239, 1),
            ),
            color: Colors.black,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 160,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(
                              pilot.flightPlan?.departure as String,
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
                              pilot.flightPlan?.arrival as String,
                              style: flightStyle,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                        pilot.flightPlan!.aircraftShort,
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
                            "Alt: ${pilot.altitude}ft",
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
                      getDistanceText(),
                      style: dataStyle,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return const Text("INVALID FLIGHT");
    }
  }
}
