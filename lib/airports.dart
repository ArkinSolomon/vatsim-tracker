import 'package:flutter/services.dart' show rootBundle;
import 'airport.dart';
import 'package:csv/csv.dart';

/// All airports referenced by its identifier (which is usually its ICAO code).
Map<String, Airport> airports = {};

/// Load the airports from the `assets/airports.csv` file into [airports].
Future<void> loadAirports() async {
  final csvStr = await rootBundle.loadString('assets/airports.csv');
  final data = const CsvToListConverter(eol: "\n", shouldParseNumbers: false)
      .convert(csvStr);
  airports = {};
  for (final row in data) {
    final newAirport = Airport(
      row[0],
      row[1],
      row[2],
      double.parse(row[3]),
      double.parse(row[4]),
      int.tryParse(row[5]) ?? 9999999,
      row[6],
      row[7],
      row[8],
      row[9],
      row[10],
      row[11],
      row[12],
    );
    airports[newAirport.ident] = newAirport;
  }
}

/// Get an airport by its identifier.
///
/// Returns null if the airport is not found. Note that [ident] (most of the
/// time) is the ICAO code.
Airport? getAirport(String ident) {
  return airports[ident];
}
