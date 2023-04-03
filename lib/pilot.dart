import 'package:vatsim_tracker/airports.dart' as airports;
import 'package:vatsim_tracker/flight_plan.dart'
    show FlightPlan, calculateDistance;

import 'airport.dart';

/// The current status of a flight
enum FlightStatus {
  /// IFR flights, pre-takeoff
  preflight, //

  /// IFR flights, in-flight
  enroute,

  /// IFR flights, after-landing
  arrived,

  /// VFR flights, in-flight
  flying,

  /// VFR flights, on the ground
  landed,

  /// Anything else, shouldn't really happen though
  unknown,
}

extension FlightStatusString on FlightStatus {
  /// Get the human readable version of the enumeration, with proper
  /// capitalization.
  String get readable {
    switch (this) {
      case FlightStatus.preflight:
        return "Pre-Flight";
      case FlightStatus.enroute:
        return "Enroute";
      case FlightStatus.arrived:
        return "Arrived";
      case FlightStatus.flying:
        return "Flying";
      case FlightStatus.landed:
        return "Landed";
      case FlightStatus.unknown:
        return "Unknown";
    }
  }
}

/// A single pilot currently connected to the network.
class Pilot {
  const Pilot({
    required this.cid,
    required this.name,
    required this.callsign,
    required this.server,
    required this.pilotRating,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.groundspeed,
    required this.transponder,
    required this.heading,
    required this.qnhIHg,
    required this.qnhMb,
    this.flightPlan,
    required this.logonTime,
    required this.lastUpdated,
  });

  final int cid;
  final String name;
  final String callsign;
  final String server;
  final int pilotRating;
  final double latitude;
  final double longitude;
  final int altitude;
  final int groundspeed;
  final String transponder;
  final int heading;
  final double qnhIHg;
  final int qnhMb;
  final FlightPlan? flightPlan;
  final DateTime logonTime;
  final DateTime lastUpdated;

  /// Get the distance from the pilots current position to the position at
  /// [latitude], [longitude] in nautical miles.
  ///
  /// This method uses the Haversine method, and takes advantage of the
  /// [calculateDistance] function.
  double getDistanceTo(double latitude, double longitude) {
    return calculateDistance(
      this.latitude,
      this.longitude,
      latitude,
      longitude,
    );
  }

  /// Calculate the distance from this pilot to the coordinates of the Airport
  /// [airport].
  ///
  /// This method takes advantage of the [getDistanceTo] method.
  double getDistanceToAirport(Airport airport) {
    return getDistanceTo(airport.latitude, airport.longitude);
  }

  /// The current status of the pilot, depending on their ground speed,
  /// flight plan type, and distance to the arrival and departure airports.
  FlightStatus get status {
    final FlightStatus noFPLStatus =
        groundspeed > 35 ? FlightStatus.flying : FlightStatus.landed;

    if (flightPlan == null ||
        flightPlan!.departure == flightPlan!.arrival ||
        flightPlan!.arrival == "NONE") {
      return noFPLStatus;
    }

    final departure = airports.getAirport(flightPlan!.departure);
    final arrival = airports.getAirport(flightPlan!.arrival);

    if (departure == null || arrival == null) {
      return noFPLStatus;
    }

    final departureDist = getDistanceToAirport(departure);
    final arrivalDist = getDistanceToAirport(arrival);

    if (groundspeed > 35) {
      return FlightStatus.enroute;
    }

    if (departureDist < 5) {
      return FlightStatus.preflight;
    } else if (arrivalDist < 5) {
      return FlightStatus.arrived;
    }

    return FlightStatus.unknown;
  }

  /// True if the pilot has a filed flightplan.
  ///
  /// True iff [flightPlan] is not `null`.
  bool get hasFlightPlan {
    return flightPlan != null;
  }
}
