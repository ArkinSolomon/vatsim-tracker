import 'package:vatsim_tracker/flight_plan.dart';
import 'package:vatsim_tracker/pilot.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Remote {
  static late List<Pilot> _pilots;

  static Future<void> updateData() async {
    final fetchUri = Uri.parse("https://data.vatsim.net/v3/vatsim-data.json");
    final response = await http.get(fetchUri);

    if (response.statusCode != 200) {
      print('Could not retrieve data');
      return;
    }

    final parsedData =
        convert.jsonDecode(response.body) as Map<String, dynamic>;

    final allPilots = List<Map<String, dynamic>>.from(parsedData["pilots"]);
    _pilots = [];

    for (final pilotData in allPilots) {
      final flightPlanData = pilotData["flight_plan"] as Map<String, dynamic>?;
      FlightPlan? flightPlan;

      if (flightPlanData != null) {
        flightPlan = FlightPlan(
          flightRules: flightPlanData["flight_rules"] == "V"
              ? FlightRules.visual
              : FlightRules.instrument,
          aircraft: flightPlanData["aircraft"],
          aircraftFaa: flightPlanData["aircraft_faa"],
          aircraftShort: flightPlanData["aircraft_short"],
          departure: flightPlanData["departure"],
          arrival: flightPlanData["arrival"],
          alternate: flightPlanData["alternate"],
          cruiseTas: flightPlanData["cruise_tas"],
          altitude: flightPlanData["altitude"],
          deptime: flightPlanData["deptime"],
          enrouteTime: flightPlanData["enroute_time"],
          fuelTime: flightPlanData["fuel_time"],
          remarks: flightPlanData["remarks"],
          route: flightPlanData["route"],
          revisionId: flightPlanData["revision_id"],
          assignedTransponder: flightPlanData["assigned_transponder"],
        );
      }

      var logonTime = DateTime.tryParse(pilotData["logon_time"]) ?? DateTime(0);
      var lastUpdated =
          DateTime.tryParse(pilotData["last_updated"]) ?? DateTime(0);

      _pilots.add(Pilot(
        cid: pilotData["cid"],
        name: pilotData["name"],
        callsign: pilotData["callsign"],
        server: pilotData["server"],
        pilotRating: pilotData["pilot_rating"],
        latitude: pilotData["latitude"],
        longitude: pilotData["longitude"],
        altitude: pilotData["altitude"],
        groundspeed: pilotData["groundspeed"],
        transponder: pilotData["transponder"],
        heading: pilotData["heading"],
        qnhIHg: pilotData["qnh_i_hg"],
        qnhMb: pilotData["qnh_mb"],
        flightPlan: flightPlan,
        logonTime: logonTime,
        lastUpdated: lastUpdated,
      ));
    }
  }

  static List<Pilot> getPilots() {
    return _pilots;
  }
}
