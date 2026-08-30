import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Identify what changed and handle "deleting a comma"
    // If the user tries to delete a comma, we actually want to delete the digit BEFORE it.
    if (oldValue.text.length > newValue.text.length &&
        oldValue.selection.baseOffset > 0 &&
        oldValue.text[oldValue.selection.baseOffset - 1] == separator) {
      final String textBeforeComma = oldValue.text.substring(0, oldValue.selection.baseOffset - 1);
      final String textAfterComma = oldValue.text.substring(oldValue.selection.baseOffset);
      
      // Delete the digit before the comma
      if (textBeforeComma.isNotEmpty) {
        final newText = textBeforeComma.substring(0, textBeforeComma.length - 1) + textAfterComma;
        final newOffset = oldValue.selection.baseOffset - 2;
        newValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newOffset >= 0 ? newOffset : 0),
        );
      }
    }

    // 2. Clean the input and validate basic structure
    String cleanedText = newValue.text.replaceAll(separator, '');
    
    // Check if it's a valid number format (allow digits and at most one dot)
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(cleanedText)) {
      return oldValue;
    }

    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // 3. Perform Formatting
    final parts = cleanedText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      try {
        final doubleValue = double.parse(integerPart);
        final formatter = NumberFormat('#,##0', 'en_US');
        formattedInteger = formatter.format(doubleValue);
      } catch (e) {
        return oldValue;
      }
    } else if (cleanedText.startsWith('.')) {
      formattedInteger = '0';
    }

    String formattedText = formattedInteger;
    if (cleanedText.contains('.')) {
      formattedText += '.';
      if (decimalPart != null) {
        formattedText += decimalPart;
      }
    }

    // 4. Calculate New Cursor Position
    // The trick is to count how many "real" (non-comma) characters were before the cursor
    // in the new text, and then place the cursor after that many real characters in the formatted text.
    
    int cursorPositionInCleaned = newValue.text.substring(0, newValue.selection.baseOffset).replaceAll(separator, '').length;
    
    int newSelectionIndex = 0;
    int realCharsCount = 0;
    
    for (int i = 0; i < formattedText.length; i++) {
      if (realCharsCount >= cursorPositionInCleaned) break;
      if (formattedText[i] != separator) {
        realCharsCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
