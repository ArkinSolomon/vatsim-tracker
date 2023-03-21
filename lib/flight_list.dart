import 'package:flutter/material.dart';
import 'package:vatsim_tracker/pilot.dart';
import 'package:vatsim_tracker/remote.dart';
import 'dart:math' as math;

import 'flight.dart';

/// A scrollable list of all pilots/flights.
class FlightList extends StatefulWidget {
  final void Function(double) _onOffsetUpdate;
  final void Function(Pilot) _onFlightClick;

  /// Create a new list of all pilots.
  ///
  /// The [onOffsetUpdate] callback is called when the widget is scrolled, with
  /// the new position of the offset as the parameter. The [onFlightClick]
  /// callback is called when a flight is clicked, with the corresponding
  /// [Pilot] as the parameter.
  FlightList({
    void Function(double)? onOffsetUpdate,
    void Function(Pilot)? onFlightClick,
    super.key,
  })  : _onFlightClick = onFlightClick ?? ((_) {}),
        _onOffsetUpdate = onOffsetUpdate ?? ((_) {});

  @override
  State<FlightList> createState() => _FlightListState();
}

class _FlightListState extends State<FlightList> {
  /// The minimum offset that the user needs to pull down on the scroll view for
  /// it to trigger a refresh.
  static const double resetOffset = -40;

  late ScrollController _scrollController;

  bool _isLoading = true;
  List<Widget> _flightChildren = [];

  ScrollUpdateNotification? _lastNotification;
  double _lastOffset = 0;

  /// Create a new scroll controller and bind the event listener.
  void _createScrollController() {
    _scrollController = ScrollController();
    _scrollController
        .addListener(() => widget._onOffsetUpdate(_scrollController.offset));
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

  /// Fetch new data from Vatsim and regenerate the list of flights.
  Future<void> _updateFlights() async {
    setState(() {
      _lastNotification = null;
      _lastOffset = 0;
      _isLoading = true;
    });

    _scrollController.dispose();
    _createScrollController();
    widget._onOffsetUpdate(0);

    await Remote.updateData();
    setState(() {
      _regenerateChildren();
      _isLoading = false;
    });
  }

  /// Regenerate the data for the flights with the current data that we have.
  void _regenerateChildren() {
    _flightChildren = [SizedBox.fromSize(size: const Size.fromHeight(20))];

    for (final pilot in Remote.pilots) {
      if (pilot.flightPlan == null) {
        continue; // TODO: Handle VFR
      }

      _flightChildren.add(Flight(
        pilot: pilot,
        onClick: widget._onFlightClick,
      ));

      _flightChildren.add(SizedBox.fromSize(
        size: const Size.fromHeight(30),
      ));
    }
    _flightChildren.add(
      SizedBox.fromSize(size: const Size.fromHeight(20)),
    );
  }

  /// This function is called whenever the scroll controller in [build] is
  /// called.
  ///
  /// It returns `true` if the notification should continue up the chain, which
  /// only occurs if [notification] is not an instance of [ScrollNotification].
  /// [_updateFlights] is called when a pull-to refresh is triggered.
  bool _onScrollControllerNotification(ScrollNotification notification) {
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
      return NotificationListener<ScrollNotification>(
        onNotification: _onScrollControllerNotification,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -30 -
                  ((double x) => x > -60 ? x : -math.pow(-x - 60, 5 / 6) - 60)(
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
