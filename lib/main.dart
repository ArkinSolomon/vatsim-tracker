import 'package:flutter/material.dart';
import 'package:vatsim_tracker/airports.dart' as airports;
import 'package:vatsim_tracker/flight_list.dart';
import 'package:vatsim_tracker/home_flight.dart';
import 'package:vatsim_tracker/remote.dart';
import 'dart:math' as math;
import 'math_utils.dart' show lerp;

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
  late HomeFlight _homeFlight;

  double _listScrollOffset = 0;

  @override
  void initState() {
    super.initState();

    const int myCID = 1404350;
    _homeFlight = HomeFlight(
        pilot: Remote.hasPilot(myCID)
            ? Remote.getPilot(myCID)
            : Remote.getRandomPilot());

    _list = FlightList(
      onOffsetUpdate: (offset) {
        setState(() {
          _listScrollOffset = offset;
        });
      },
      onFlightClick: (pilot) {
        setState(() {
          _homeFlight = HomeFlight(pilot: pilot);
        });
      },
    );
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
            Column(
              children: [
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
                        (_listScrollOffset < 0
                                ? _listScrollOffset * -1
                                : _listScrollOffset) /
                            30),
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
