enum Facility {
  observer,
  flightServiceStation,
  clearanceDelivery,
  ground,
  tower,
  apporachDeparture,
  enroute
}

extension FacilityExt on Facility {
  String get long {
    switch (this) {
      case Facility.observer:
        return "Observer";
      case Facility.flightServiceStation:
        return "Flight Service Station";
      case Facility.clearanceDelivery:
        return "Clearance Delivery";
      case Facility.ground:
        return "Ground";
      case Facility.tower:
        return "Tower";
      case Facility.apporachDeparture:
        return "Apporach/Departure";
      case Facility.enroute:
        return "Enroute";
    }
  }

  String get short {
    switch (this) {
      case Facility.observer:
        return "OBS";
      case Facility.flightServiceStation:
        return "FSS";
      case Facility.clearanceDelivery:
        return "DEL";
      case Facility.ground:
        return "GND";
      case Facility.tower:
        return "TWR";
      case Facility.apporachDeparture:
        return "APP";
      case Facility.enroute:
        return "CTR";
    }
  }

  static Facility fromId(int id) {
    switch (id) {
      case 0:
        return Facility.observer;
      case 1:
        return Facility.flightServiceStation;
      case 2:
        return Facility.clearanceDelivery;
      case 3:
        return Facility.ground;
      case 4:
        return Facility.tower;
      case 5:
        return Facility.apporachDeparture;
      case 6:
        return Facility.enroute;
      default:
        throw Exception("Invalid facility id: $id");
    }
  }
}
