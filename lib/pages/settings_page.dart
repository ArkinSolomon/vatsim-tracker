import 'package:flutter/material.dart' hide Page;
import 'package:vatsim_tracker/pages/page.dart';
import 'package:vatsim_tracker/pages/page_background_tab.dart';

import '../text_input.dart';

class SettingsPage extends Page {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const PageBackgroundTab(height: 100),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontFamily: "AzeretMono",
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  height: 65,
                  child: const TextInput(
                    label: "My CID",
                    prompt: "Enter your Vatsim CID",
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
