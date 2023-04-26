import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:vatsim_tracker/data/pilot.dart';
import 'package:vatsim_tracker/pages/main_page.dart';
import 'package:vatsim_tracker/pages/more_page.dart';

import '../main.dart';

enum ActivePage {
  main,
  more,
}

/// A base class for all pages to inherit from to allow easy page switching.
abstract class Page extends StatefulWidget {
  static late final PageManagerState manager;

  static late final Page _cachedMainPage;

  static Page initMainPage(PageManagerState manager) {
    Page.manager = manager;
    _cachedMainPage = MainPage(key: GlobalKey(debugLabel: "main_page"));
    return _cachedMainPage;
  }

  const Page({
    super.key,
  });

  static setPage(ActivePage page, {Object? data}) {
    switch (page) {
      case ActivePage.main:
        manager.setPage(page, _cachedMainPage);
        break;
      case ActivePage.more:
        manager.setPage(page, MorePage(data as Pilot));
    }
  }

  Tuple2<Icon, void Function()> topLeftIconData() {
    return Tuple2(
      const Icon(
        Icons.menu,
        color: Colors.white,
      ),

      // We wrap the function in another function because initially it's null
      () => manager.scaffoldKey.currentState!.openDrawer(),
    );
  }
}
