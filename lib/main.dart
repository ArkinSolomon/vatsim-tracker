import 'package:flutter/material.dart' hide Page;
import 'package:tuple/tuple.dart';
import 'package:vatsim_tracker/data/airports.dart' as airports;
import 'package:vatsim_tracker/data/remote.dart';
import 'package:vatsim_tracker/pages/page.dart';
import 'package:vatsim_tracker/pages/main_page.dart';

import 'dart:math' as math;

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
      home: PageManager(),
    );
  }
}

class PageManager extends StatefulWidget {
  const PageManager({super.key});

  @override
  State<PageManager> createState() => PageManagerState();
}

class PageManagerState extends State<PageManager> {
  ActivePage page = ActivePage.main;
  late Page displayedPage;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Replace the widget with a new page
  void setPage(ActivePage page, Page displayedPage) {
    setState(() {
      this.page = page;
      this.displayedPage = displayedPage;
    });
  }

  @override
  void initState() {
    super.initState();
    displayedPage = Page.initMainPage(this);
  }

  @override
  Widget build(BuildContext context) {
    Tuple2 menuIconData = displayedPage.topLeftIconData();

    return Scaffold(
      key: scaffoldKey,
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
            Positioned(
              left: 10,
              top: 35,
              child: IconButton(
                iconSize: 40,
                icon: menuIconData.item1,
                onPressed: menuIconData.item2,
              ),
            ),
            displayedPage
          ],
        ),
      ),
      drawer: Drawer(
          child: Column(
        children: const [
          Text("HELLO"),
          Text("HELLO"),
          Text("HELLO"),
          Text("HELLO"),
          Text("HELLO"),
          Text("HELLO")
        ],
      )),
    );
  }
}
