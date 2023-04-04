import 'package:flutter/material.dart';
import 'package:vatsim_tracker/pages/main_page.dart';

import '../main.dart';

enum ActivePage {
  main,
}

/// A base class for all pages to inherit from to allow easy page switching.
abstract class Page extends StatefulWidget {
  final PageManagerState manager;

  const Page({
    required this.manager,
    super.key,
  });

  setPage(ActivePage page) {
    switch (page) {
      case ActivePage.main:
        manager.setPage(page, MainPage(manager: manager));
        break;
    }
  }
}
