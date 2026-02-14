import 'package:budget_wise/shared/utils/all_phosphor_icons.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

extension PhosPhorEx on PhosphorIcons {
  List<IconData> allRegularIcons() {
    return AllIcons.regularIcons.values.toList();
  }

  List<IconData> allBoldIcons() {
    return AllIcons.boldIcons.values.toList();
  }

  List<IconData> allDuoToneIcons() {
    return AllIcons.duotoneIcons.values.toList();
  }

  List<IconData> allFilledIcons() {
    return AllIcons.fillIcons.values.toList();
  }

  List<IconData> allLightIcons() {
    return AllIcons.lightIcons.values.toList();
  }

  List<IconData> allThinIcons() {
    return AllIcons.thinIcons.values.toList();
  }
}
