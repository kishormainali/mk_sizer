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
    required super.child,
  });

  final Size size;
  final Size designSize;

  double get scaleWidth => size.width / designSize.width;

  double get scaleHeight => size.height / designSize.height;

  double get scaleRadius => min(scaleWidth, scaleHeight);

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
      size != old.size || designSize != old.designSize;

  @override
  bool updateShouldNotifyDependent(
    MKSizerModel old,
    Set<MKAspect> dependencies,
  ) {
    final w =
        size.width != old.size.width ||
        designSize.width != old.designSize.width;
    final h =
        size.height != old.size.height ||
        designSize.height != old.designSize.height;
    return (dependencies.contains(MKAspect.width) && w) ||
        (dependencies.contains(MKAspect.height) && h) ||
        (dependencies.contains(MKAspect.text) && w);
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

  double sp(num v) => v * MKSizerModel.of(this, MKAspect.text).scaleWidth;

  double pw(num v) => v * MKSizerModel.of(this, MKAspect.width).size.width;

  double ph(num v) => v * MKSizerModel.of(this, MKAspect.height).size.height;
}
