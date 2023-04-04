import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vatsim_tracker/data/airport.dart';

import 'data/airports.dart' as airports;

/// Calculate the distance between two points on the globe using the Haversine
/// method.
///
/// The value returned is in nautical miles.
///
/// Also see https://stackoverflow.com/questions/54138750/total-distance-calculation-from-latlng-list
double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = math.pi / 180;
  var a = 0.5 -
      math.cos((lat2 - lat1) * p) / 2 +
      math.cos(lat1 * p) *
          math.cos(lat2 * p) *
          (1 - math.cos((lon2 - lon1) * p)) /
          2;
  return 12742 * math.asin(math.sqrt(a)) / 1.852;
}

/// A single flightplan for IFR flight.
@immutable
class FlightPlan {
  const FlightPlan({
    required this.flightRules,
    required this.aircraft,
    required this.aircraftFaa,
    required this.aircraftShort,
    required this.departure,
    required this.arrival,
    required this.alternate,
    required this.altitude,
    required this.cruiseTas,
    required this.deptime,
    required this.enrouteTime,
    required this.fuelTime,
    required this.remarks,
    required this.route,
    required this.revisionId,
    required this.assignedTransponder,
  });

  final FlightRules flightRules;
  final String aircraft;
  final String aircraftFaa;
  final String aircraftShort;
  final String departure;
  final String arrival;
  final String alternate;
  final String altitude;
  final String cruiseTas;
  final String deptime;
  final String enrouteTime;
  final String fuelTime;
  final String remarks;
  final String route;
  final int revisionId;
  final String assignedTransponder;

  /// Get the total distance between the departure and arrival airports.
  ///
  /// `-1` is returned if the departure or arrival airport is not found.
  double getDistance() {
    Airport? departureAirport = airports.getAirport(departure);
    Airport? arrivalAirport = airports.getAirport(arrival);
    if (departureAirport == null || arrivalAirport == null) {
      return -1;
    }

    return calculateDistance(
      departureAirport.latitude,
      departureAirport.longitude,
      arrivalAirport.latitude,
      arrivalAirport.longitude,
    );
  }
}

enum FlightRules { instrument, visual }
