import 'package:AnimatedRail/AnimatedRail/AnimatedRailRaw.dart';
import 'package:flutter/material.dart';

/// rail item used by the Animated rail as a tab
/// values like [background],[activeColor] and [iconColor]
/// overrides default values in the [AnimatedRailRaw]
class RailItem {
  /// tab icon to use prefered to be an [Icon]
  Widget icon;

  /// string label
  String label;

  /// `required` screen to show when this [RailItem] is selected
  Widget screen;

  /// default icon background color
  final Color background;

  /// default active color for text and icon
  final Color activeColor;

  /// default inactive icon and text color
  final Color iconColor;

  RailItem({
    @required this.icon,
    @required this.screen,
    this.label,
    this.background,
    this.activeColor,
    this.iconColor,
  });
}
