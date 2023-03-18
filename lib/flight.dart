import 'package:flutter/material.dart';
import 'dart:math' show pi;

import 'package:vatsim_tracker/pilot.dart';

class Flight extends StatelessWidget {
  const Flight(this.pilot, {super.key});

  final Pilot pilot;

  static const TextStyle flightStyle =
      TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 120,
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
                  Align(
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: const Icon(
                        Icons.airplanemode_active_rounded,
                        color: Colors.blueGrey,
                        size: 32,
                      ),
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
            )
          ],
        ),
      ),
    );
  }
}
