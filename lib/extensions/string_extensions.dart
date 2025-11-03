import 'package:flutter/material.dart';

extension StringExtensions on String {
  bool isValidEmail() {
    const pattern = r"[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+ ";
    return isNotEmpty && !RegExp(pattern).hasMatch(this);
  }

  Color toColor() {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) {
      buffer.write('ff');
    }

    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Uri toUri() {
    return Uri.parse(this);
  }
}
