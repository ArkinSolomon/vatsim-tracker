import 'package:vatsim_tracker/airports.dart' as airports;
import 'package:vatsim_tracker/flight_plan.dart'
    show FlightPlan, calculateDistance;

import 'airport.dart';

enum FlightStatus {
  preflight, // IFR, pre-takeoff
  enroute, // IFR, in-flight
  arrived, // IFR, after-landing
  flying, // VFR, in-flight
  landed, // VFR, on-ground
  unknown,
}

extension FlightStatusString on FlightStatus {
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

  double getDistanceTo(double latitude, double longitude) {
    return calculateDistance(
      this.latitude,
      this.longitude,
      latitude,
      longitude,
    );
  }

  double getDistanceToAirport(Airport airport) {
    return getDistanceTo(airport.latitude, airport.longitude);
  }

  FlightStatus get status {
    final departure = airports.getAirport(flightPlan!.departure);
    final arrival = airports.getAirport(flightPlan!.arrival);

    if (flightPlan == null ||
        departure == null ||
        arrival == null ||
        flightPlan!.departure == flightPlan!.arrival ||
        flightPlan!.arrival == "NONE") {
      return groundspeed > 35 ? FlightStatus.flying : FlightStatus.flying;
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
}
