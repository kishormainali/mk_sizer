part of 'mk_widget.dart';

/// A [SizedBox] that can be `const`: [width] scales with `.w` and [height]
/// with `.h`, re-scaling when the screen size changes.
///
/// ```dart
/// const MKSizedBox(width: 100, height: 48, child: Text('Hi'))
/// ```
class MKSizedBox extends SizedBox {
  const MKSizedBox({super.key, super.width, super.height, super.child});

  BoxConstraints _constraints(BuildContext context) => BoxConstraints.tightFor(
    width: width == null ? null : width! * context.w(1),
    height: height == null ? null : height! * context.h(1),
  );

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) =>
      RenderConstrainedBox(additionalConstraints: _constraints(context));

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedBox renderObject,
  ) {
    renderObject.additionalConstraints = _constraints(context);
  }
}
