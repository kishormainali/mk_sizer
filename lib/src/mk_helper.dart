/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */

part of 'mk_widget.dart';

/// Raw per-axis scale of [size] against [designSize].
///
/// When [respectAspectRatio] is true, width/height are blended toward their
/// average as the device's aspect ratio diverges from the design's, so
/// elements scale less independently (less stretch) on screens with a very
/// different shape than the design (e.g. a wide tablet vs. a narrow phone
/// mockup). On a device whose aspect ratio matches the design's exactly,
/// this is a no-op. [minScaleFactor]/[maxScaleFactor] then clamp the result.
({double width, double height}) _computeScales(
  Size size,
  Size designSize, {
  bool respectAspectRatio = false,
  double? minScaleFactor,
  double? maxScaleFactor,
}) {
  final rawWidth = size.width / designSize.width;
  final rawHeight = size.height / designSize.height;
  if (!respectAspectRatio) return (width: rawWidth, height: rawHeight);

  final deviceAspect = size.width / size.height;
  final designAspect = designSize.width / designSize.height;
  // 1 when the aspect ratios match, shrinking toward 0 as they diverge.
  final aspectRatio = deviceAspect <= designAspect
      ? deviceAspect / designAspect
      : designAspect / deviceAspect;
  final blend = 1 - aspectRatio;

  final mean = (rawWidth + rawHeight) / 2;
  var width = rawWidth + (mean - rawWidth) * blend;
  var height = rawHeight + (mean - rawHeight) * blend;
  if (minScaleFactor != null) {
    width = max(width, minScaleFactor);
    height = max(height, minScaleFactor);
  }
  if (maxScaleFactor != null) {
    width = min(width, maxScaleFactor);
    height = min(height, maxScaleFactor);
  }
  return (width: width, height: height);
}

class MKHelper {
  MKHelper._();

  factory MKHelper() {
    return _instance;
  }

  static final MKHelper _instance = MKHelper._();

  /// default size of figma/adobe xd design
  static const Size defaultSize = Size(360, 690);

  // Defaults keep `.w`/`.h`/`.sp` usable (as 1:1) before an MKSizer has laid out.

  /// device screen width
  double _screenWidth = 0;

  ///device screen height
  double _screenHeight = 0;

  ///scale width
  double _scaleWidth = 1;

  ///scale height
  double _scaleHeight = 1;

  ///smaller of the width/height scales, cached for [radius]
  double _scaleRadius = 1;

  ///text scale factor
  double _textScaleFactor = 1;

  static Size _size = Size.zero;
  static Size _designSize = Size.zero;
  static bool _respectAspectRatio = false;
  static double? _minScaleFactor;
  static double? _maxScaleFactor;
  static double? _minTextScaleFactor;
  static double? _maxTextScaleFactor;

  /// Whether any input differs from what was last passed to [init].
  static bool changed(
    Size size,
    Size designSize, {
    bool respectAspectRatio = false,
    double? minScaleFactor,
    double? maxScaleFactor,
    double? minTextScaleFactor,
    double? maxTextScaleFactor,
  }) =>
      size != _size ||
      designSize != _designSize ||
      respectAspectRatio != _respectAspectRatio ||
      minScaleFactor != _minScaleFactor ||
      maxScaleFactor != _maxScaleFactor ||
      minTextScaleFactor != _minTextScaleFactor ||
      maxTextScaleFactor != _maxTextScaleFactor;

  /// Sets the scale factors for a screen of [size] against [designSize].
  ///
  /// See [_computeScales] for [respectAspectRatio]/[minScaleFactor]/
  /// [maxScaleFactor]. [minTextScaleFactor]/[maxTextScaleFactor] separately
  /// clamp the text scale (`.sp`), so text can be kept more (or less)
  /// uniform across devices than layout dimensions.
  static void init({
    required Size size,
    Size designSize = defaultSize,
    bool respectAspectRatio = false,
    double? minScaleFactor,
    double? maxScaleFactor,
    double? minTextScaleFactor,
    double? maxTextScaleFactor,
  }) {
    assert(
      designSize.width > 0 && designSize.height > 0,
      'designSize must be positive',
    );
    _size = size;
    _designSize = designSize;
    _respectAspectRatio = respectAspectRatio;
    _minScaleFactor = minScaleFactor;
    _maxScaleFactor = maxScaleFactor;
    _minTextScaleFactor = minTextScaleFactor;
    _maxTextScaleFactor = maxTextScaleFactor;
    final scales = _computeScales(
      size,
      designSize,
      respectAspectRatio: respectAspectRatio,
      minScaleFactor: minScaleFactor,
      maxScaleFactor: maxScaleFactor,
    );
    var textScale = scales.width;
    if (minTextScaleFactor != null) {
      textScale = max(textScale, minTextScaleFactor);
    }
    if (maxTextScaleFactor != null) {
      textScale = min(textScale, maxTextScaleFactor);
    }
    _instance
      .._screenWidth = size.width
      .._screenHeight = size.height
      .._scaleWidth = scales.width
      .._scaleHeight = scales.height
      .._scaleRadius = min(scales.width, scales.height)
      .._textScaleFactor = textScale;
  }

  double get width => _screenWidth;

  double get height => _screenHeight;

  double setWidth(num width) => width * _scaleWidth;

  double setHeight(num height) => height * _scaleHeight;

  /// Text scales with width only (unlike [radius], which uses the smaller axis).
  double setSp(num sp) => sp * _textScaleFactor;

  double radius(num r) => r * _scaleRadius;

  Widget setVerticalSpacing(num height) => SizedBox(height: setHeight(height));

  Widget setVerticalSpacingRadius(num height) =>
      SizedBox(height: radius(height));

  Widget setHorizontalSpacing(num width) => SizedBox(width: setWidth(width));

  Widget setHorizontalSpacingRadius(num width) =>
      SizedBox(width: radius(width));
}
