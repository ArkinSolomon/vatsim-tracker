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
}

enum FlightRules { instrument, visual }
