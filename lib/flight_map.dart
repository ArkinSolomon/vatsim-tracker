import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import 'package:vatsim_tracker/data/airport.dart';
import 'package:vatsim_tracker/data/airports.dart';
import 'package:vatsim_tracker/flight_plan.dart';
import 'dart:math' as math;

import 'data/pilot.dart';

const double markerSize = 25;

/// How much to increase the arc by in degrees.
const double arcIncreaseFactor = 1.1;

/// Increase the arc between the two points by a factor of [arcIncreaseFactor].
///
/// Using the extended arc as the bounds of the map prevents the markers from
/// being on the very edge of the map display.
Tuple2<LatLng, LatLng> increaseArc(LatLng pos1, LatLng pos2) {
  double lat1 = pos1.latitude;
  double long1 = pos1.longitude;
  double lat2 = pos2.latitude;
  double long2 = pos2.longitude;

  // if (lat1 < 0) {
  //   lat1 += 360;
  // }
  // if (long1 < 0) {
  //   long1 += 360;
  // }
  // if (lat2 < 0) {
  //   lat2 += 360;
  // }
  // if (long2 < 0) {
  //   long2 += 360;
  // }

  if (lat1 < lat2) {
    lat1 *= -arcIncreaseFactor / 2;
    lat2 *= arcIncreaseFactor / 2;
  } else {
    lat1 *= arcIncreaseFactor / 2;
    lat2 *= arcIncreaseFactor / 2;
  }

  if (long1 < long2) {
    long1 *= -arcIncreaseFactor / 2;
    long2 *= arcIncreaseFactor / 2;
  } else {
    long1 *= arcIncreaseFactor / 2;
    long2 *= -arcIncreaseFactor / 2;
  }

  return Tuple2(LatLng(lat1, long1), LatLng(lat2, long2));
}

/// A simple map that displays a pilots location, estimated traveled path, and
/// estimated path to travel.
class FlightMap extends StatelessWidget {
  final Pilot pilot;

  const FlightMap(this.pilot, {super.key});

  Widget _plannedFlightWidget() {
    FlightPlan flightPlan = pilot.flightPlan!;

    Airport? departure = getAirport(flightPlan.departure);
    Airport? arrival = getAirport(flightPlan.arrival);

    if (departure == null || arrival == null) {
      return const Center(
        child: Text("UNKNOWN AIRPORT"),
      );
    }

    final LatLng depCoords = LatLng(
      departure.latitude,
      departure.longitude,
    );

    final LatLng arrCoords = LatLng(
      arrival.latitude,
      arrival.longitude,
    );

    final LatLng pilotCoords = LatLng(pilot.latitude, pilot.longitude);

    final Tuple2<LatLng, LatLng> increasedArcs =
        increaseArc(depCoords, arrCoords);

    final LatLng bound1 = increasedArcs.item1;
    final LatLng bound2 = increasedArcs.item2;

    return FlutterMap(
      options: MapOptions(
        bounds: LatLngBounds(bound1, bound2),
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'net.arkinsolomon.vatsim_tracker',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [depCoords, pilotCoords],
              color: Colors.green,
            ),
            Polyline(
              points: [pilotCoords, arrCoords],
              isDotted: true,
              color: const Color.fromARGB(181, 76, 175, 79),
            )
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: depCoords,
              width: markerSize,
              height: markerSize,
              anchorPos:
                  AnchorPos.exactly(Anchor(markerSize / 2, markerSize * 0.1)),
              builder: (context) => const Icon(
                Icons.location_pin,
                size: markerSize,
                color: Color.fromARGB(255, 211, 161, 12),
              ),
            ),
            Marker(
              point: arrCoords,
              width: markerSize,
              height: markerSize,
              anchorPos:
                  AnchorPos.exactly(Anchor(markerSize / 2, markerSize * 0.1)),
              builder: (context) => const Icon(
                Icons.location_pin,
                size: markerSize,
                color: Color.fromARGB(255, 211, 161, 12),
              ),
            ),
            Marker(
              point: pilotCoords,
              builder: (context) => Transform.rotate(
                angle: pilot.heading * math.pi / 180,
                child: const Icon(
                  Icons.airplanemode_on_outlined,
                  color: Color.fromARGB(255, 13, 91, 117),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pilot.hasFlightPlan) {
      return _plannedFlightWidget();
    }
    return const Center(
      child: Text("UNPLANNED FLIGHT MAP"),
    );
  }
}
