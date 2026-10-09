part of 'mk_widget.dart';

/// What a widget scales with. Widgets rebuild only when their aspect changes.
enum MKAspect { width, height, text }

/// Provides the scale factors to the tree so widgets can subscribe to them
/// with `context.w(10)`, `context.h(10)`, etc.
class MKSizerModel extends InheritedModel<MKAspect> {
  const MKSizerModel({
    super.key,
    required this.size,
    required this.designSize,
    this.respectAspectRatio = false,
    this.minScaleFactor,
    this.maxScaleFactor,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
    this.heightFromWidth = false,
    required super.child,
  });

  final Size size;
  final Size designSize;
  final bool respectAspectRatio;
  final double? minScaleFactor;
  final double? maxScaleFactor;

  /// Clamp applied to [scaleText] independently of [minScaleFactor]/
  /// [maxScaleFactor], so text can stay more (or less) uniform across
  /// devices than layout dimensions.
  final double? minTextScaleFactor;
  final double? maxTextScaleFactor;

  /// `.h` uses the width scale (see [MKHeightMode.width]).
  final bool heightFromWidth;

  ({double width, double height}) get _scales => _computeScales(
    size,
    designSize,
    respectAspectRatio: respectAspectRatio,
    minScaleFactor: minScaleFactor,
    maxScaleFactor: maxScaleFactor,
    heightFromWidth: heightFromWidth,
  );

  double get scaleWidth => _scales.width;

  double get scaleHeight => _scales.height;

  double get scaleRadius => min(scaleWidth, scaleHeight);

  double get scaleText {
    var text = scaleWidth;
    if (minTextScaleFactor != null) text = max(text, minTextScaleFactor!);
    if (maxTextScaleFactor != null) text = min(text, maxTextScaleFactor!);
    return text;
  }

  static MKSizerModel of(BuildContext context, MKAspect aspect) {
    final model = InheritedModel.inheritFrom<MKSizerModel>(
      context,
      aspect: aspect,
    );
    if (model == null) {
      throw FlutterError('No MKSizer found above this context.');
    }
    return model;
  }

  @override
  bool updateShouldNotify(MKSizerModel old) =>
      heightFromWidth != old.heightFromWidth ||
      size != old.size ||
      designSize != old.designSize ||
      respectAspectRatio != old.respectAspectRatio ||
      minScaleFactor != old.minScaleFactor ||
      maxScaleFactor != old.maxScaleFactor ||
      minTextScaleFactor != old.minTextScaleFactor ||
      maxTextScaleFactor != old.maxTextScaleFactor;

  @override
  bool updateShouldNotifyDependent(
    MKSizerModel old,
    Set<MKAspect> dependencies,
  ) {
    // Blending, height-from-width, and clamps couple both axes, so any
    // input change can affect both scaleWidth and scaleHeight.
    final coupled =
        respectAspectRatio ||
        old.respectAspectRatio ||
        heightFromWidth ||
        old.heightFromWidth;
    final optionsChanged =
        heightFromWidth != old.heightFromWidth ||
        respectAspectRatio != old.respectAspectRatio ||
        minScaleFactor != old.minScaleFactor ||
        maxScaleFactor != old.maxScaleFactor;
    final w =
        optionsChanged ||
        (coupled && size != old.size) ||
        size.width != old.size.width ||
        designSize.width != old.designSize.width ||
        (coupled && designSize != old.designSize);
    final h =
        optionsChanged ||
        (coupled && size != old.size) ||
        size.height != old.size.height ||
        designSize.height != old.designSize.height ||
        (coupled && designSize != old.designSize);
    final text =
        w ||
        minTextScaleFactor != old.minTextScaleFactor ||
        maxTextScaleFactor != old.maxTextScaleFactor;
    return (dependencies.contains(MKAspect.width) && w) ||
        (dependencies.contains(MKAspect.height) && h) ||
        (dependencies.contains(MKAspect.text) && text);
  }
}

/// Context based sizing. Unlike `10.w`, these rebuild the calling widget when
/// the size changes, so they also work inside `const` subtrees.
extension MKContextX on BuildContext {
  double w(num v) => v * MKSizerModel.of(this, MKAspect.width).scaleWidth;

  double h(num v) => v * MKSizerModel.of(this, MKAspect.height).scaleHeight;

  /// Uses the smaller of the width/height scales, so depends on both.
  double r(num v) {
    MKSizerModel.of(this, MKAspect.width);
    return v * MKSizerModel.of(this, MKAspect.height).scaleRadius;
  }

  double sp(num v) => v * MKSizerModel.of(this, MKAspect.text).scaleText;

  double pw(num v) => v * MKSizerModel.of(this, MKAspect.width).size.width;

  double ph(num v) => v * MKSizerModel.of(this, MKAspect.height).size.height;
}
