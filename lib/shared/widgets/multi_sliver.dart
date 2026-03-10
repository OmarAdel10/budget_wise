import 'package:flutter/material.dart';

class MultiSliver extends StatelessWidget {
  final List<Widget> slivers;
  const MultiSliver({super.key, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: slivers);
  }
}
