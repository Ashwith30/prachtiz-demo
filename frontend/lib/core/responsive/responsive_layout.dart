import 'package:flutter/material.dart';
import 'device_type.dart';
import 'responsive_builder.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final bool useScreenSize;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.useScreenSize = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      useScreenSize: useScreenSize,
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop;
        }
      },
    );
  }
}
