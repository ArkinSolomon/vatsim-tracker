import 'dart:async';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:intl/intl.dart';

import 'dart:math' as math;
import '../math_utils.dart' show abs, lerp;

import '../data/pilot.dart';
import '../data/remote.dart';
import '../flight_list.dart';
import '../home_flight.dart';
import './page.dart';

/// The height of the widget displayed at the top of the home page.
const double myFlightHeight = 400;

/// The application's home page.
class MainPage extends Page {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    if (Remote.hasPilot(myCID)) {
      _homeFlight = HomeFlight(pilot: Remote.getPilot(myCID));
    } else {
      _homeFlight = HomeFlight(pilot: Remote.getRandomPilot());
    }

    Remote.addUpdateListener(_updateHomeFlight);

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

  @override
  void dispose() {
    Remote.removeUpdateListener(_updateHomeFlight);

    super.dispose();
  }

  void _updateHomeFlight() {
    Pilot old = _homeFlight.getPilot();

    if (Remote.hasPilot(old.cid)) {
      _homeFlight.setPilot(Remote.getPilot(old.cid));
    } else {
      _homeFlight.setPilot(Remote.getRandomPilot());
    }

    // Force refresh to update updated time at the top
    setState(() {});
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
    } else
      _headTextType = newHeadTextType;
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

  /// Scale the height of the header based on how much the list has scrolled.
  double _getAllFlightLabelHeight() {
    const double initialHeight = 28;
    const double finalHeight = 22;
    const double requiedOffset = 250;

    if (_listScrollOffset <= 0) {
      return initialHeight;
    } else if (_listScrollOffset >= requiedOffset) {
      return finalHeight;
    }
    return ((finalHeight - initialHeight) / requiedOffset) * _listScrollOffset +
        initialHeight;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                height: MediaQuery.of(context).size.height -
                    myFlightHeight * (43 / 90),
              ),
            ],
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  myFlightHeight -
                  MediaQuery.of(context).padding.top,
              child: _list,
            ),
          ),
          SizedBox(
            height: myFlightHeight,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: _homeFlight,
            ),
          ),
          Positioned(
            top: myFlightHeight - _getAllFlightLabelHeight() * 1.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "All flights:",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "AzeretMono",
                  fontSize:
                      _getAllFlightLabelHeight(), // scale with list offset
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // The shadow that appears after you start scrolling
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
    );
  }
}
