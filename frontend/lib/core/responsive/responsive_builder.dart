import 'package:flutter/material.dart';
export 'device_type.dart';
import 'device_type.dart';
import 'breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  final bool useScreenSize;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.useScreenSize = true,
  });

  static DeviceType getDeviceType(double width) {
    if (width < Breakpoints.mobileMax) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tabletMax) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return getDeviceType(width);
  }

  @override
  Widget build(BuildContext context) {
    if (useScreenSize) {
      final width = MediaQuery.sizeOf(context).width;
      final deviceType = getDeviceType(width);
      return builder(context, deviceType);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(constraints.maxWidth);
        return builder(context, deviceType);
      },
    );
  }
}

extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveBuilder.deviceTypeOf(this);
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
}
