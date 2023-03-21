import 'package:flutter/material.dart';
import 'package:vatsim_tracker/airports.dart' as airports;
import 'package:vatsim_tracker/flight_list.dart';
import 'package:vatsim_tracker/home_flight.dart';
import 'package:vatsim_tracker/remote.dart';
import 'dart:math' as math;

/// The height of the widget displayed at the top of the home page.
const double myFlightHeight = 400;

/// Initialization code.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Remote.updateData();
  await airports.loadAirports();
  runApp(const VatsimTracker());
}

/// Linearly interpolate between [a] and [b], at [f].
///
/// [f] will be clamped between zero and one.
double lerp(double a, double b, double f) {
  f = f.clamp(0, 1);
  return a * (1.0 - f) + (b * f);
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
    _homeFlight = HomeFlight(pilot: Remote.getRandomPilot());

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
            colors: [
              Color.fromARGB(255, 74, 7, 61),
              Color.fromARGB(255, 44, 15, 93),
              Colors.black,
            ],
            transform: GradientRotation(math.pi / 2),
          ),
        ),
        child: Stack(
          children: [
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
