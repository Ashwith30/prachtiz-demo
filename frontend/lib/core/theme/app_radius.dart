import 'package:flutter/material.dart';

class AppRadius {
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r18 = 18.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;

  // BorderRadius shapes
  static final BorderRadius radius8 = BorderRadius.circular(r8);
  static final BorderRadius radius12 = BorderRadius.circular(r12);
  static final BorderRadius radius16 = BorderRadius.circular(r16);
  static final BorderRadius radius18 = BorderRadius.circular(r18);
  static final BorderRadius radius20 = BorderRadius.circular(r20);
  static final BorderRadius radius24 = BorderRadius.circular(r24);

  // RoundedRectangleBorder shapes for buttons and cards
  static final RoundedRectangleBorder border12 = RoundedRectangleBorder(borderRadius: radius12);
  static final RoundedRectangleBorder border16 = RoundedRectangleBorder(borderRadius: radius16);
  static final RoundedRectangleBorder border18 = RoundedRectangleBorder(borderRadius: radius18);
  static final RoundedRectangleBorder border20 = RoundedRectangleBorder(borderRadius: radius20);
  static final RoundedRectangleBorder border24 = RoundedRectangleBorder(borderRadius: radius24);
}
