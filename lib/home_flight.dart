import 'package:vatsim_tracker/flight_plan.dart';
import 'package:vatsim_tracker/gradient_button.dart';
import 'package:vatsim_tracker/pages/main_page.dart';

import 'data/airports.dart' as airports;
import 'package:flutter/material.dart' hide Page;
import 'package:vatsim_tracker/progress_circle.dart';
import 'data/pilot.dart';
import 'flight.dart' show setMaxLen;
import 'math_utils.dart' show abs;
import 'dart:math' as math;
import 'pages/page.dart';

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

  static const TextStyle unplannedHeadStyle = TextStyle(
    color: Colors.white,
    fontFamily: "AzeretMono",
    fontSize: 35,
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
    return "Flown ${abs(flightPlanDistance - pilotDistance)}nm of ${flightPlanDistance}nm";
  }

  Widget _moreButton() {
    return GradientButton(
      width: 110,
      height: 40,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => Page.setPage(ActivePage.more, data: pilot),
      gradient: const LinearGradient(
        begin: Alignment(-0.3, -2.2),
        end: Alignment(0, -0.4),
        colors: [
          Color.fromARGB(255, 74, 7, 61),
          Color.fromARGB(255, 54, 15, 83),
        ],
        transform: GradientRotation(math.pi / 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.map_outlined,
            color: Colors.white,
            size: 25,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            "More",
            style: TextStyle(
              fontFamily: "AzeretMono",
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: () => print("MORE BUTTON"),
      child: Container(
        width: 100,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment(-0.3, -2.2),
            end: Alignment(0, -0.4),
            colors: [
              Color.fromARGB(255, 74, 7, 61),
              Color.fromARGB(255, 54, 15, 83),
            ],
            transform: GradientRotation(math.pi / 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.map_outlined,
              color: Colors.white,
              size: 25,
            ),
            SizedBox(
              width: 6,
            ),
            Text(
              "More",
              style: TextStyle(
                fontFamily: "AzeretMono",
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment(-0.3, -2.2),
          end: Alignment(0, -0.4),
          colors: [
            Color.fromARGB(255, 74, 7, 61),
            Color.fromARGB(255, 54, 15, 83),
          ],
          transform: GradientRotation(math.pi / 2),
        ),
      ),
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.map_outlined,
          color: Colors.white,
          size: 25,
        ),
        onPressed: () => print("MORE"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        label: const Text(
          "More",
          style: TextStyle(
            fontFamily: "AzeretMono",
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  /// The general data that is displayed for a pilot regardless of if they have
  /// a filed flight plan.
  Widget _bodyStatistics(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: myFlightHeight / 2 + 55,
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
    );
  }

  /// The widget that's displayed if the pilot has a flight plan.
  Widget _plannedFlightWidget(BuildContext context) {
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

    return Stack(
      children: [
        ProgressCircle(
          progress: progress,
          padding: 100,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Text(pilot.callsign, style: headDataTextStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child:
                      Text(flightPlan.aircraftShort, style: headDataTextStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text("Status: ${pilot.status.readable}",
                      style: headDataTextStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child:
                      Text(setMaxLen(pilot.name, 24), style: headDataTextStyle),
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
            padding: const EdgeInsets.only(left: 20, right: 20),
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
        Align(
          child: _moreButton(),
        ),
        _bodyStatistics(context)
      ],
    );
  }

  /// The widget that's displayed if the pilot does not have a fligth plan.
  Widget _unplannedFlightWidget() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: myFlightHeight / 10),
          child: Center(
            child: Column(
              children: [
                Text(
                  pilot.callsign,
                  style: unplannedHeadStyle,
                ),
                Text(
                  pilot.name,
                  style: headDataTextStyle,
                ),
                const SizedBox(
                  height: 60,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "This pilot has not filed a flight plan for this flight.",
                    style: bodyTextStyle,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
        _bodyStatistics(context)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pilot.hasFlightPlan) {
      return _plannedFlightWidget(context);
    }
    return _unplannedFlightWidget();
  }
}
