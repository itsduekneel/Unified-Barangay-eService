import 'package:flutter/material.dart';

/// Navigates instantly (no animation).
Route instantRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, _, _) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
