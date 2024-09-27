import 'package:flutter/material.dart';

import 'package:prompt_dialog/prompt_dialog.dart';

class TextInput extends StatefulWidget {
  final String label;
  final String prompt;
  final String? defaultValue;

  const TextInput({
    required this.label,
    required this.prompt,
    this.defaultValue,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late String value;

  static const _labelStyle = TextStyle(
    fontFamily: "AzeretMono",
    fontWeight: FontWeight.bold,
  );
  static const _previewStyle = TextStyle(fontFamily: "AzeretMono");
  static const _updateButtonStyle = TextStyle(
      fontFamily: "AzeretMono",
      color: Color.fromARGB(255, 54, 15, 83),
      fontWeight: FontWeight.w500);

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        String? newValue = await prompt(
          context,
          title: Text(
            widget.prompt,
            style: _labelStyle.merge(const TextStyle(fontSize: 14)),
          ),
          initialValue: value,
          textOK: Text(
            "Update",
            style: _updateButtonStyle
                .merge(const TextStyle(fontWeight: FontWeight.w900)),
          ),
          textCancel: const Text(
            "Cancel",
            style: _updateButtonStyle,
          ),
          maxLines: 1,
          validator: (str) => str != null && RegExp(r"^\d{6}$").hasMatch(str)
              ? null
              : "Invalid CID",
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 54, 15, 83)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 54, 15, 83)),
            ),
          ),
        );
        setState(() => value = newValue ?? "");
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.label,
            style: _labelStyle,
          ),
          Expanded(
            child: Text(
              value == "" ? "<unknown>" : value,
              style: _previewStyle,
              textAlign: TextAlign.right,
            ),
          )
        ],
      ),
    );
  }
}
