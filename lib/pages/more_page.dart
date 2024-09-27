import 'package:flutter/material.dart' hide Page;
import 'package:tuple/tuple.dart';
import 'package:vatsim_tracker/flight.dart';
import 'package:vatsim_tracker/flight_map.dart';
import 'package:vatsim_tracker/pages/page.dart';
import 'package:vatsim_tracker/pages/page_background_tab.dart';

import '../data/pilot.dart';

class MorePage extends Page {
  final Pilot pilot;

  const MorePage(this.pilot, {super.key});

  @override
  Tuple2<Icon, void Function()> topLeftIconData() {
    return Tuple2(
      const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      () => Page.setPage(ActivePage.main),
    );
  }

  @override
  State<StatefulWidget> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          const PageBackgroundTab(height: 400 * (43 / 90)),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 50,
                ),
                child: Flight(
                  pilot: widget.pilot,
                  onClick: (_) {},
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                height: 230,
                child: FlightMap(widget.pilot),
              )
            ],
          ),
        ],
      ),
    );
  }
}
