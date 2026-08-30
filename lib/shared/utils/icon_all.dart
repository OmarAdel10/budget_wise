import 'package:budget_wise/shared/utils/all_phosphor_icons.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

extension PhosPhorEx on PhosphorIcons {
  List<IconData> allRegularIcons() {
    return AllIcons.regularIcons.values.toList();
  }

  List<IconData> allBoldIcons() {
    return AllIcons.boldIcons.values.toList();
  }

  List<IconData> allFilledIcons() {
    return AllIcons.fillIcons.values.toList();
  }

  Map<String, IconData> get allRegularIconsWithName => AllIcons.regularIcons;

  Map<String, IconData> get allBoldIconsWithName => AllIcons.boldIcons;

  Map<String, IconData> get allFilledIconsWithName => AllIcons.fillIcons;
}
