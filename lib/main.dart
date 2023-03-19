import 'package:flutter/material.dart';
import 'package:vatsim_tracker/airports.dart' as airports;
import 'package:vatsim_tracker/flight_list.dart';
import 'package:vatsim_tracker/remote.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Remote.updateData();
  await airports.loadAirports();
  runApp(const VatsimTracker());
}

double lerp(double a, double b, double f) {
  f = f.clamp(0, 1);
  return a * (1.0 - f) + (b * f);
}

class VatsimTracker extends StatelessWidget {
  const VatsimTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vatsim Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(title: 'Vatsim Tracker'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double myFlightHeight = 400;
  late final FlightList _list; // We'll have to change this on refresh
  double _listScrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _list = FlightList((offset) {
      setState(() {
        _listScrollOffset = offset;
      });
    });
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
              child: ClipRect(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - myFlightHeight,
                  child: _list,
                ),
              ),
            ),
            const SizedBox(
              height: myFlightHeight,
              child: Center(
                child: Text("hello"),
              ),
            ),
            Positioned(
              top: myFlightHeight,
              child: ClipRect(
                child: Transform.rotate(
                  angle: math.pi,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: lerp(0, 30, _listScrollOffset / 30),
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
