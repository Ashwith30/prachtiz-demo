import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppSpacing {
  // Numeric values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Integrated Gap Widgets for convenience
  static const Widget gapXs = Gap(xs);
  static const Widget gapSm = Gap(sm);
  static const Widget gapMd = Gap(md);
  static const Widget gapLg = Gap(lg);
  static const Widget gapXl = Gap(xl);
  static const Widget gapXxl = Gap(xxl);

  // EdgeInset paddings for common layouts
  static const EdgeInsets pXs = EdgeInsets.all(xs);
  static const EdgeInsets pSm = EdgeInsets.all(sm);
  static const EdgeInsets pMd = EdgeInsets.all(md);
  static const EdgeInsets pLg = EdgeInsets.all(lg);
  static const EdgeInsets pXl = EdgeInsets.all(xl);

  // Symmetric paddings
  static const EdgeInsets pxSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets pySm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets pxMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pyMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets pxLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets pyLg = EdgeInsets.symmetric(vertical: lg);
}
