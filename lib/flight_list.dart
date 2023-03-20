import 'package:flutter/material.dart';
import 'package:vatsim_tracker/pilot.dart';
import 'package:vatsim_tracker/remote.dart';
import 'dart:math' as math;

import 'flight.dart';

class FlightList extends StatefulWidget {
  final void Function(double) onOffsetUpdate;
  final void Function(Pilot) onFlightClick;

  const FlightList(
      {required this.onOffsetUpdate, required this.onFlightClick, super.key});

  @override
  State<FlightList> createState() => _FlightListState();
}

class _FlightListState extends State<FlightList> {
  static const double resetOffset = -40;

  late ScrollController _scrollController;

  bool _isLoading = true;
  List<Widget> _flightChildren = [];

  ScrollUpdateNotification? _lastNotification;
  double _lastOffset = 0;

  void _createScrollController() {
    _scrollController = ScrollController();
    _scrollController
        .addListener(() => widget.onOffsetUpdate(_scrollController.offset));
  }

  @override
  void initState() {
    super.initState();
    _createScrollController();
    Remote.updateData().then((value) {
      _regenerateChildren();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      } else {
        _isLoading = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateFlights() async {
    setState(() {
      _lastNotification = null;
      _lastOffset = 0;
      _isLoading = true;
    });

    _scrollController.dispose();
    _createScrollController();
    widget.onOffsetUpdate(0);

    await Remote.updateData();
    setState(() {
      _regenerateChildren();
      _isLoading = false;
    });
  }

  void _regenerateChildren() {
    _flightChildren = [SizedBox.fromSize(size: const Size.fromHeight(20))];
    var pilots = Remote.getPilots();

    for (final pilot in pilots) {
      if (pilot.flightPlan == null) {
        continue; // TODO: Handle VFR
      }

      _flightChildren.add(Flight(
        pilot: pilot,
        onClick: widget.onFlightClick,
      ));

      _flightChildren.add(SizedBox.fromSize(
        size: const Size.fromHeight(30),
      ));
    }
    _flightChildren.add(
      SizedBox.fromSize(size: const Size.fromHeight(20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Fetching latest data from vatsim servers",
            style: TextStyle(color: Colors.white),
          ),
          Image(
            height: 128,
            width: 128,
            image: AssetImage("assets/placeholder_loading.gif"),
          )
        ],
      );
    } else {
      return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (_lastNotification != null &&
                _lastNotification!.dragDetails != null &&
                notification.dragDetails == null &&
                _lastOffset < resetOffset) {
              _updateFlights();
              return false;
            }

            _lastNotification = notification;
            setState(() {
              _lastOffset = _scrollController.offset;
            });
            return false;
          }
          return true;
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -30 -
                  ((double x) => x > -80 ? x : -math.pow(-x - 80, 5 / 6) - 80)(
                          _lastOffset) *
                      1.2,
              child: Text(
                (() {
                  return _lastOffset < resetOffset
                      ? "Release to refresh"
                      : "Pull to refresh";
                })(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            SingleChildScrollView(
              controller: _scrollController,
              clipBehavior: Clip.hardEdge,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: _flightChildren,
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
