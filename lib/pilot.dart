import 'package:vatsim_tracker/flight_plan.dart';

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
}
