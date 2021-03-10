import 'package:flutter/material.dart';

extension DarkAwareTheme on ThemeData {
  Color colorUnlessDark(Color color) =>
      brightness == Brightness.light ? color : colorScheme.onSurface;
  Color darkAwareColor({required Color onDark, required Color onLight}) =>
      brightness == Brightness.light ? onLight : onDark;
}
