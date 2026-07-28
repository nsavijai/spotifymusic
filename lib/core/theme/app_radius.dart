import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;

  static BorderRadius get circularXs => BorderRadius.circular(xs);
  static BorderRadius get circularSm => BorderRadius.circular(sm);
  static BorderRadius get circularMd => BorderRadius.circular(md);
  static BorderRadius get circularLg => BorderRadius.circular(lg);
  static BorderRadius get circularXl => BorderRadius.circular(xl);
  static BorderRadius get circularXxl => BorderRadius.circular(xxl);
  static BorderRadius get circularFull => BorderRadius.circular(full);
}
