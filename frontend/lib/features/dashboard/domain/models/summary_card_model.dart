import 'package:flutter/material.dart';

class SummaryCardModel {
  final String title;
  final String value;
  final double changePercentage;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<double> sparklineData;

  const SummaryCardModel({
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.sparklineData,
  });
}
