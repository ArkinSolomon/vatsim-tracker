import 'package:flutter/material.dart';

/// A single airport as read in from the `assets/airports.csv` file.
@immutable
class Airport {
  final String ident;
  final String type;
  final String name;
  final double latitude;
  final double longitude;
  final int elevation;
  final String continent;
  final String country;
  final String region;
  final String city;
  final String? gps;
  final String? iata;
  final String? local;

  const Airport(
    this.ident,
    this.type,
    this.name,
    this.latitude,
    this.longitude,
    this.elevation,
    this.continent,
    this.country,
    this.region,
    this.city,
    this.gps,
    this.iata,
    this.local,
  );
}
