part of 'mk_widget.dart';

/// A [Padding] that can be `const`: horizontal insets scale with `.w` and
/// vertical insets with `.h`, re-scaling when the screen size changes.
///
/// ```dart
/// const MKPadding(padding: EdgeInsets.all(16), child: Text('Hi'))
/// ```
class MKPadding extends Padding {
  const MKPadding({super.key, required super.padding, super.child});

  EdgeInsets _scaled(BuildContext context, TextDirection direction) {
    final p = padding.resolve(direction);
    return EdgeInsets.fromLTRB(
      context.w(p.left),
      context.h(p.top),
      context.w(p.right),
      context.h(p.bottom),
    );
  }

  @override
  RenderPadding createRenderObject(BuildContext context) {
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return RenderPadding(
      padding: _scaled(context, direction),
      textDirection: direction,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPadding renderObject) {
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    renderObject
      ..padding = _scaled(context, direction)
      ..textDirection = direction;
  }
}
