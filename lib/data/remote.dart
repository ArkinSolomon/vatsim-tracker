import 'package:vatsim_tracker/data/facility.dart';
import 'package:vatsim_tracker/flight_plan.dart';
import 'package:vatsim_tracker/data/pilot.dart';
import 'package:http/http.dart' as http;
import 'package:vatsim_tracker/data/rating.dart';
import 'dart:convert' as convert;
import 'dart:math' as math;
import 'controller.dart';

final _random = math.Random();

/// This retrieves, parses, and stores data from the Vatsim network, and stores
/// it staticly.
class Remote {
  /// All of the pilots indexed by their CID.
  static late Map<int, Pilot> _pilots;

  /// All of the controllers indexed by their callsign.
  static late Map<String, Controller> _controllers;

  static final Set<void Function()> _updateListeners = {};

  static void addUpdateListener(void Function() listener) =>
      _updateListeners.add(listener);
  static void removeUpdateListener(void Function() listener) =>
      _updateListeners.remove(listener);

  static late DateTime _lastUpdated;

  /// The UTC time of when the data was last fetched from remote.
  static DateTime get lastUpdated {
    return _lastUpdated;
  }

  /// Update the currently data from the Vatsim network.
  ///
  /// This function must be called before attempting to retrieve any data from
  /// other methods or properties of this class, otherwise an exception will be
  /// thrown, or the data will be empty. This method should also be called
  /// periodically to get the most up to date information.
  static Future<void> updateData() async {
    final fetchUri = Uri.parse("https://data.vatsim.net/v3/vatsim-data.json");
    final response = await http.get(fetchUri);

    if (response.statusCode != 200) {
      print("Could not retrieve data from the vatsim network");
      return;
    }

    final parsedData =
        convert.jsonDecode(response.body) as Map<String, dynamic>;

    final allPilots = List<Map<String, dynamic>>.from(parsedData["pilots"]);
    _pilots = {};

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

      final logonTime =
          DateTime.tryParse(pilotData["logon_time"]) ?? DateTime(0);
      final lastUpdated =
          DateTime.tryParse(pilotData["last_updated"]) ?? DateTime(0);

      final int cid = pilotData["cid"];
      _pilots[cid] = Pilot(
        cid: cid,
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
      );
    }

    final allControllers =
        List<Map<String, dynamic>>.from(parsedData["controllers"]);
    _controllers = {};

    for (final controllerData in allControllers) {
      final logonTime =
          DateTime.tryParse(controllerData["logon_time"]) ?? DateTime(0);
      final lastUpdated =
          DateTime.tryParse(controllerData["last_updated"]) ?? DateTime(0);

      final String callsign = controllerData["callsign"];

      _controllers[callsign] = Controller(
        cid: controllerData["cid"],
        name: controllerData["name"],
        callsign: controllerData["callsign"],
        frequency: controllerData["frequency"],
        facility: FacilityExt.fromId(controllerData["facility"]),
        rating: RatingExt.fromId(controllerData["rating"]),
        server: controllerData["server"],
        visualRange: controllerData["visual_range"],
        textAtis: controllerData["text_atis"] == null
            ? null
            : List<String>.from(controllerData["text_atis"]),
        lastUpdated: lastUpdated,
        logonTime: logonTime,
      );
    }

    _lastUpdated = DateTime.now().toUtc();
    _notifyListeners();
  }

  /// Get a list of all the pilots connected to the network.
  static List<Pilot> get pilots {
    return _pilots.values.toList();
  }

  /// Get a list of all the controllers connected to the network.
  static List<Controller> get controllers {
    return _controllers.values.toList();
  }

  /// Get a pilot by their [cid].
  ///
  /// An exception is thrown if we do not have data on the pilot with the CID
  /// [cid].
  static Pilot getPilot(int cid) {
    final pilot = _pilots[cid];

    if (pilot == null) {
      throw Exception("No pilot with CID $cid found on remote");
    }

    return pilot;
  }

  /// Get a random pilot connected to the network.
  ///
  /// An exception is thrown in the pilot list is empty.
  static Pilot getRandomPilot() {
    if (_pilots.isEmpty) {
      throw Exception("Can not get pilot before fetching data from server.");
    }
    return _pilots[_pilots.keys.toList()[_random.nextInt(_pilots.length)]]!;
  }

  /// Check if the pilot with the CID [cid] is currently connected to the
  /// network.
  ///
  /// Returns true if the pilot is connected, or false otherwise.
  static bool hasPilot(int cid) {
    return _pilots.containsKey(cid);
  }

  /// Notify all update listners that the data has been updated.
  static _notifyListeners() {
    for (final callback in _updateListeners) {
      callback();
    }
  }
}
