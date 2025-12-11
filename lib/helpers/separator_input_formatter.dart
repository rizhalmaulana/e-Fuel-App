import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return oldValue;
    }

    int value = int.parse(newText);

    final formatter = NumberFormat('#,###', 'id_ID');
    String newString = formatter.format(value);
    int selectionIndex = newString.length - (newValue.text.length - newValue.selection.end);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(
        offset: selectionIndex.clamp(0, newString.length),
      ),
    );
  }
}