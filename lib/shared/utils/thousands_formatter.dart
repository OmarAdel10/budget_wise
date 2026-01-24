import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Strip existing separators
    String cleanedText = newValue.text.replaceAll(separator, '');

    // Prevent more than one decimal point
    if (cleanedText.split('.').length > 2) {
      return oldValue;
    }

    // Check if it's a valid number format (allow digits and at most one dot)
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(cleanedText)) {
      return oldValue;
    }

    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final parts = cleanedText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Format integer part
    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      try {
        final doubleValue = double.parse(integerPart);
        // Use #,##0 to ensure at least one digit is shown (e.g., for "0")
        final formatter = NumberFormat('#,##0', 'en_US');
        formattedInteger = formatter.format(doubleValue);
        
        // If the user typed leading zeros, double.parse strips them.
        // But for things like "0.05", we want to keep the "0".
        // NumberFormat('#,##0') handles "0" correctly.
        // If the user types "00", it becomes "0".
      } catch (e) {
        return oldValue;
      }
    } else if (cleanedText.startsWith('.')) {
      // Allow ".5" -> it will be treated as "0.5" by many parsers, 
      // but here we just keep it as is or prepend a 0.
      formattedInteger = '0';
    }

    String formattedText = formattedInteger;
    if (cleanedText.contains('.')) {
      formattedText += '.';
      if (decimalPart != null) {
        formattedText += decimalPart;
      }
    }

    // Basic cursor management: if the cursor was at the end, keep it at the end.
    int selectionIndex = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}