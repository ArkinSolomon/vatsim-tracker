import 'package:vatsim_tracker/data/facility.dart';
import 'package:vatsim_tracker/data/rating.dart';

class Controller {
  const Controller({
    required this.cid,
    required this.name,
    required this.callsign,
    required this.frequency,
    required this.facility,
    required this.rating,
    required this.server,
    required this.visualRange,
    required this.textAtis,
    required this.lastUpdated,
    required this.logonTime,
  });

  final int cid;
  final String name;
  final String callsign;
  final String frequency;
  final Facility facility;
  final Rating rating;
  final String server;
  final int visualRange;
  final List<String>? textAtis;
  final DateTime lastUpdated;
  final DateTime logonTime;
}
