/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */

part of 'mk_widget.dart';

/// A responsive equivalent of `package:gap`'s `SliverGap` widget: a sliver
/// that takes a fixed amount of space, scaling [value] with
/// [MKHelper.setWidth] when the enclosing [Scrollable]'s axis is horizontal
/// and [MKHelper.setHeight] when vertical.
///
/// Use this inside a [CustomScrollView] (or any other sliver-based scroll
/// view); see [MKGap] for the `Row`/`Column`/`Flex` equivalent.
class MKSliverGap extends LeafRenderObjectWidget {
  /// Creates a sliver that takes a responsive [value] of space.
  const MKSliverGap(this.value, {super.key, this.color})
    : assert(
        value >= 0 && value < double.infinity,
        'value must be positive and finite',
      );

  /// Design-space size; scaled by [MKHelper] depending on the sliver's axis.
  final num value;

  /// The color used to fill the gap.
  final Color? color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MKRenderSliverGap(value: value, color: color);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    MKRenderSliverGap renderObject,
  ) {
    renderObject
      ..value = value
      ..color = color;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('value', value.toDouble()));
    properties.add(ColorProperty('color', color));
  }
}

class MKRenderSliverGap extends RenderSliver {
  MKRenderSliverGap({required num value, Color? color})
    : _value = value,
      _color = color;

  num get value => _value;
  num _value;
  set value(num value) {
    if (_value != value) {
      _value = value;
      markNeedsLayout();
    }
  }

  Color? get color => _color;
  Color? _color;
  set color(Color? value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  /// Unlike [_RenderMKGap], a sliver always knows its axis directly from
  /// [SliverConstraints.axis], so there's no `RenderFlex`/[Scrollable]
  /// detection needed here.
  double get _mainAxisExtent {
    switch (constraints.axis) {
      case Axis.horizontal:
        return MKHelper().setWidth(_value);
      case Axis.vertical:
        return MKHelper().setHeight(_value);
    }
  }

  @override
  void performLayout() {
    final mainAxisExtent = _mainAxisExtent;
    final paintExtent = calculatePaintOffset(
      constraints,
      from: 0,
      to: mainAxisExtent,
    );
    final cacheExtent = calculateCacheOffset(
      constraints,
      from: 0,
      to: mainAxisExtent,
    );

    assert(paintExtent.isFinite);
    assert(paintExtent >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: mainAxisExtent,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: mainAxisExtent,
      hitTestExtent: paintExtent,
      hasVisualOverflow:
          mainAxisExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (color != null) {
      final paint = Paint()..color = color!;
      final size = constraints
          .asBoxConstraints(
            minExtent: geometry!.paintExtent,
            maxExtent: geometry!.paintExtent,
          )
          .constrain(Size.zero);
      context.canvas.drawRect(offset & size, paint);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('mainAxisExtent', _mainAxisExtent));
    properties.add(ColorProperty('color', color));
  }
}
