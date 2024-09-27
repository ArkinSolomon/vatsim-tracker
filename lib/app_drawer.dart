import 'package:flutter/material.dart' hide Page, DrawerButton;
import 'package:vatsim_tracker/pages/page.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'drawer_button.dart';

/// The drawer that displays on the left side of the app
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  PackageInfo _info = PackageInfo(
    appName: "---",
    packageName: "---",
    version: "0.0.0",
    buildNumber: "0",
  );

  static final TextStyle _footerStyle = TextStyle(
    fontFamily: "AzeretMono",
    color: Colors.grey.shade400,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        setState(() {
          _info = packageInfo;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerButton(
              text: "Home",
              onClick: () {
                Page.setPage(ActivePage.main);
                Navigator.pop(context);
              },
            ),
            DrawerButton(
              text: "Settings",
              onClick: () {
                Page.setPage(ActivePage.settings);
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                "${_info.appName} v${_info.version}\n©2023 Arkin Solomon.\nNot for real life use.",
                textAlign: TextAlign.center,
                style: _footerStyle,
              ),
            )
          ],
        ),
      ),
    );
  }
}
