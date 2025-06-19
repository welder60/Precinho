import 'package:flutter/services.dart';

import 'formatters.dart';

/// [TextInputFormatter] that formats the input as a monetary value using
/// Brazilian conventions. Only digits are accepted and a comma is
/// automatically inserted for the two decimal places.
class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = double.parse(digits) / 100;
    final newText = Formatters.formatPriceValue(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
