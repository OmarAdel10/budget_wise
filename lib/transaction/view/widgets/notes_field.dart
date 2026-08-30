import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';

class NotesField extends StatelessWidget {
  final TextEditingController controller;
  final TransactionType selectedType;

  const NotesField({
    super.key,
    required this.controller,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {

    final noteLabel = selectedType == TransactionType.transfer
        ? context.l10n.note
        : context.l10n.hint;

    final noteHint = selectedType == TransactionType.transfer
        ? context.l10n.transferNoteHint
        : context.l10n.noteHint;

    return CustomTextField(
      label: noteLabel,
      hintText: noteHint,
      controller: controller,
      maxLines: null,
      minLines: 1,
      hasOriginalInputDecoration: false,
    );
  }
}
