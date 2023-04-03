import 'dart:async';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vatsim_tracker/airports.dart' as airports;
import 'package:vatsim_tracker/flight_list.dart';
import 'package:vatsim_tracker/home_flight.dart';
import 'package:vatsim_tracker/pilot.dart';
import 'package:vatsim_tracker/remote.dart';
import 'dart:math' as math;
import 'math_utils.dart' show abs, lerp;

/// The height of the widget displayed at the top of the home page.
const double myFlightHeight = 400;

/// Initialization code.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Remote.updateData();
  await airports.loadAirports();
  runApp(const VatsimTracker());
}

/// Main app widget.
class VatsimTracker extends StatelessWidget {
  const VatsimTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vatsim Tracker',
      home: HomePage(),
    );
  }
}

/// The homepage of the application.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FlightList _list;
  late final HomeFlight _homeFlight;

  double _listScrollOffset = 0;
  late DateTime _currentTime;

  late int _headTextType = 0;

  final cron = Cron();

  static final _zuluFormat = DateFormat("HHmm");
  static final _lastUpdatedFormat = DateFormat("HHmm:ss");

  static const TextStyle topText = TextStyle(
    color: Colors.white,
    fontFamily: "AzeretMono",
    fontSize: 12,
  );

  @override
  void initState() {
    super.initState();

    const int myCID = 1404350;
    _homeFlight = HomeFlight(
        pilot: Remote.hasPilot(myCID)
            ? Remote.getPilot(myCID)
            : Remote.getRandomPilot());

    Remote.addUpdateListener(() {
      Pilot old = _homeFlight.getPilot();

      if (Remote.hasPilot(old.cid)) {
        _homeFlight.setPilot(Remote.getPilot(old.cid));
      } else {
        _homeFlight.setPilot(Remote.getRandomPilot());
      }

      // Force refresh to update updated time at the top
      setState(() {});
    });

    _list = FlightList(
      onOffsetUpdate: (offset) {
        setState(() {
          _listScrollOffset = offset;
        });
      },
      onFlightClick: _homeFlight.setPilot,
    );

    _currentTime = DateTime.now().toUtc();

    _updateHeader();
    Timer.periodic(const Duration(seconds: 10), (_) {
      _updateHeader();
    });

    cron.schedule(Schedule.parse("* * * * *"), () {
      setState(() {
        _currentTime = DateTime.now().toUtc();
      });
    });
  }

  void _updateHeader() {
    int newHeadTextType = 0;
    if (DateTime.now().second >= 45) {
      newHeadTextType = 1;
    } else if (DateTime.now().second >= 30) {
      newHeadTextType = 0;
    } else if (DateTime.now().second >= 15) {
      newHeadTextType = 1;
    }

    if (newHeadTextType == _headTextType) {
      return;
    }

    if (mounted) {
      setState(() {
        _headTextType = newHeadTextType;
      });
    }
  }

  /// Get the text that is supposed to be on the left side at the bar on top.
  String _getHeadTextLeft() {
    switch (_headTextType) {
      case 0:
        return "${Remote.pilots.length} Pilots";
      case 1:
        return "${_zuluFormat.format(_currentTime)} ZULU";
      default:

        // No setState() because we don't want to trigger a rebuild
        _headTextType = 0;
        return _getHeadTextLeft();
    }
  }

  /// Similar to [_getHeadTextLeft], gets whats supposed ot be on the right side
  /// on top.
  String _getHeadTextRight() {
    switch (_headTextType) {
      case 0:
        return "${Remote.controllers.length} Controllers";
      case 1:
        return "Updated ${_lastUpdatedFormat.format(Remote.lastUpdated)}";
      default:
        _headTextType = 0;
        return _getHeadTextRight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.3, -0.2),
            end: Alignment(0, 0.4),
            colors: [
              Color.fromARGB(255, 74, 7, 61),
              Color.fromARGB(255, 54, 15, 83),
              Colors.black,
            ],
            transform: GradientRotation(math.pi / 2),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
              child: SizedBox(
                height: 12,
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        " | ",
                        style: topText,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _getHeadTextLeft(),
                                style: topText,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _getHeadTextRight(),
                                style: topText,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                // This expanded container sticks the white background to the
                // bottom
                Expanded(child: Container()),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(35)),
                  ),
                  height: MediaQuery.of(context).size.height -
                      myFlightHeight * (43 / 90),
                ),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height - myFlightHeight,
                child: _list,
              ),
            ),
            SizedBox(
              height: myFlightHeight,
              child: _homeFlight,
            ),

            // The shadow that appears after yous tart scrolling
            Positioned(
              top: myFlightHeight,
              child: ClipRect(
                child: Transform.rotate(
                  angle: math.pi,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: lerp(
                        0,
                        30,
                        // Get the absolute value of the offset
                        abs(_listScrollOffset) / 30),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10.0,
                          offset: Offset(
                            0,
                            15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
