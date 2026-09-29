/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */

part of 'mk_widget.dart';

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

  /// Whether [size]/[designSize] differ from what was last passed to [init].
  static bool changed(Size size, Size designSize) =>
      size != _size || designSize != _designSize;

  /// Sets the scale factors for a screen of [size] against [designSize].
  static void init({required Size size, Size designSize = defaultSize}) {
    assert(
      designSize.width > 0 && designSize.height > 0,
      'designSize must be positive',
    );
    _size = size;
    _designSize = designSize;
    final scaleWidth = size.width / designSize.width;
    _instance
      .._screenWidth = size.width
      .._screenHeight = size.height
      .._scaleWidth = scaleWidth
      .._scaleHeight = size.height / designSize.height
      .._scaleRadius = min(scaleWidth, size.height / designSize.height)
      .._textScaleFactor = scaleWidth;
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
