import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vatsim_tracker/pilot.dart';
import 'package:vatsim_tracker/remote.dart';
import 'dart:math' as math;
import 'math_utils.dart' show lerp, smoothstep, abs;

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

class _FlightListState extends State<FlightList>
    with SingleTickerProviderStateMixin {
  /// The minimum offset that the user needs to pull down on the scroll view for
  /// it to trigger a refresh.
  static const double resetOffset = -70;

  static const Duration refreshBounceDuration = Duration(milliseconds: 300);

  late ScrollController _scrollController;

  bool _isLoading = true;
  List<Widget> _flightChildren = [];

  ScrollUpdateNotification? _lastNotification;

  /// The offset of the last time we checked it.
  double _lastOffset = 0;

  /// The position of the refresh text/loading symbol when the refresh was
  /// triggerd last.
  double _triggeredRefreshOffset = 0;

  /// The time the refresh was last triggered.
  DateTime _triggeredRefreshTime = DateTime.fromMillisecondsSinceEpoch(0);

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
        setState(() {
          _triggeredRefreshOffset = _lastOffset;
          _triggeredRefreshTime = DateTime.now();
          _lastOffset = 0;
        });

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

  /// The loading icon and refresh text that appears when pulling to refresh.
  Widget _refreshDisplay() {
    final String text;

    if (_isLoading) {
      text = "Fetching the latest data\nfrom Vatsim servers";
    } else {
      text =
          _lastOffset < resetOffset ? "Release to refresh" : "Pull to refresh";
    }

    final textWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontFamily: "AzeretMono",
        fontSize: 18,
      ),
    );

    const double spinnerRadius = 15;
    final CupertinoActivityIndicator spinnerWidget;
    final double spinnerProgress = abs(_lastOffset / resetOffset).toDouble();
    if (_isLoading || spinnerProgress > 1) {
      spinnerWidget = const CupertinoActivityIndicator(radius: spinnerRadius);
    } else {
      spinnerWidget = CupertinoActivityIndicator.partiallyRevealed(
        radius: spinnerRadius,
        progress: spinnerProgress,
      );
    }

    double currentOffset;
    if (_isLoading) {
      final progress = (DateTime.now().millisecondsSinceEpoch -
              _triggeredRefreshTime.millisecondsSinceEpoch) /
          refreshBounceDuration.inMilliseconds;

      if (progress < 1) {
        final smoothedPos = smoothstep(
          0,
          1,
          progress,
        );
        currentOffset = lerp(_triggeredRefreshOffset, resetOffset, smoothedPos);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      } else {
        currentOffset = resetOffset;
      }
    } else {
      currentOffset = _lastOffset;
    }

    return Positioned(
      top: -50 - _getRefreshTextOffset(currentOffset),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: textWidget,
        ),
        spinnerWidget,
      ]),
    );
  }

  static double _getRefreshTextOffset(x) {
    return x >= resetOffset
        ? x
        : (-math.pow(resetOffset - x, 5 / 6) + resetOffset);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollControllerNotification,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _refreshDisplay(),
          !_isLoading
              ? ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: Remote.pilots.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Flight(
                        pilot: Remote.pilots[index],
                        onClick: widget._onFlightClick,
                      ),
                    );
                  },
                )
              : Container()
        ],
      ),
    );
  }
}
