import 'package:flutter/material.dart';
import 'package:vatsim_tracker/remote.dart';

import 'flight.dart';

class FlightList extends StatefulWidget {
  final void Function(double) onOffsetUpdate;

  const FlightList(this.onOffsetUpdate, {super.key});

  void _offsetUpdated(double offset) {
    onOffsetUpdate(offset);
  }

  @override
  State<FlightList> createState() => _FlightListState();
}

class _FlightListState extends State<FlightList> {
  bool _isLoading = true;
  List<Widget> _flightChildren = [];
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController
        .addListener(() => widget._offsetUpdated(_scrollController.offset));

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
      _isLoading = true;
    });
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

      _flightChildren.add(Flight(pilot));

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
      return const Center(child: Text("Loading..."));
    } else {
      return SingleChildScrollView(
        controller: _scrollController,
        clipBehavior: Clip.none,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: _flightChildren,
          ),
        ),
      );
    }
  }
}
