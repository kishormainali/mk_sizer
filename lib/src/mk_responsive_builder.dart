/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */

part of 'mk_widget.dart';

/// Device tier based on the nearest [MediaQuery] width.
enum MKDeviceType { smallMobile, mobile, tablet, desktop }

/// Renders a different widget per device tier, based on the nearest
/// [MediaQuery] width. Falls back to the next-smaller tier's builder (and
/// ultimately to [mobile]) when a tier's builder isn't provided.
class MKResponsiveBuilder extends StatelessWidget {
  const MKResponsiveBuilder({
    super.key,
    required this.mobile,
    this.smallMobile,
    this.tablet,
    this.desktop,
    this.smallMobileBreakpoint = 360,
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 1024,
  }) : assert(
         smallMobileBreakpoint < tabletBreakpoint &&
             tabletBreakpoint < desktopBreakpoint,
         'breakpoints must be strictly increasing',
       );

  /// Below [smallMobileBreakpoint]. Falls back to [mobile] if not set.
  final WidgetBuilder? smallMobile;

  /// Between [smallMobileBreakpoint] and [tabletBreakpoint]. Also the
  /// fallback for every other tier, so it's required.
  final WidgetBuilder mobile;

  /// Between [tabletBreakpoint] and [desktopBreakpoint]. Falls back to
  /// [mobile] if not set.
  final WidgetBuilder? tablet;

  /// At or above [desktopBreakpoint]. Falls back to [tablet], then [mobile],
  /// if not set.
  final WidgetBuilder? desktop;

  final double smallMobileBreakpoint;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  /// The device tier for [context]'s nearest [MediaQuery] width, using the
  /// default breakpoints (360 / 600 / 1024).
  static MKDeviceType deviceTypeOf(
    BuildContext context, {
    double smallMobileBreakpoint = 360,
    double tabletBreakpoint = 600,
    double desktopBreakpoint = 1024,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return MKDeviceType.desktop;
    if (width >= tabletBreakpoint) return MKDeviceType.tablet;
    if (width < smallMobileBreakpoint) return MKDeviceType.smallMobile;
    return MKDeviceType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = deviceTypeOf(
      context,
      smallMobileBreakpoint: smallMobileBreakpoint,
      tabletBreakpoint: tabletBreakpoint,
      desktopBreakpoint: desktopBreakpoint,
    );
    final builder = switch (deviceType) {
      MKDeviceType.desktop => desktop ?? tablet ?? mobile,
      MKDeviceType.tablet => tablet ?? mobile,
      MKDeviceType.smallMobile => smallMobile ?? mobile,
      MKDeviceType.mobile => mobile,
    };
    return builder(context);
  }
}

/// Picks a value based on [BuildContext]'s device tier, e.g.
/// `context.resValue(mobile: 16.0, tablet: 24.0, desktop: 32.0)`.
extension MKResponsiveContextX on BuildContext {
  /// The device tier for the nearest [MediaQuery] width, using the default
  /// breakpoints (360 / 600 / 1024).
  MKDeviceType get deviceType => MKResponsiveBuilder.deviceTypeOf(this);

  /// Returns the value for the current device tier, falling back to the
  /// next-smaller tier's value (and ultimately [mobile]) when unset.
  T resValue<T>({T? smallMobile, required T mobile, T? tablet, T? desktop}) {
    return switch (deviceType) {
      MKDeviceType.desktop => desktop ?? tablet ?? mobile,
      MKDeviceType.tablet => tablet ?? mobile,
      MKDeviceType.smallMobile => smallMobile ?? mobile,
      MKDeviceType.mobile => mobile,
    };
  }
}
