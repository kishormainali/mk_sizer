/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */

part of 'mk_widget.dart';

/// A responsive equivalent of `package:gap`'s `Gap` widget: it takes a fixed
/// amount of space in the direction of its parent [Flex] (or [Scrollable]),
/// scaling [value] with [MKHelper.setWidth] when that direction is
/// horizontal and [MKHelper.setHeight] when vertical, so the same `10.gap`
/// call is correct inside both a [Row] and a [Column].
///
/// It only works in the following cases:
/// - It is a descendant of a [Row], [Column], or [Flex], and the path from
/// this widget to its enclosing [Flex] must contain only
/// [StatelessWidget]s or [StatefulWidget]s (not other kinds of widgets,
/// like [RenderObjectWidget]s).
/// - It is a descendant of a [Scrollable].
class MKGap extends StatelessWidget {
  /// Creates a widget that takes a responsive amount of space in the
  /// direction of its parent.
  const MKGap(this.value, {super.key, this.color})
    : assert(value >= 0, 'value must be positive');

  /// Design-space size; scaled by [MKHelper] depending on the detected axis.
  final num value;

  /// The color used to fill the gap.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scrollableState = Scrollable.maybeOf(context);
    final axisDirection = scrollableState?.axisDirection;
    final fallbackDirection = axisDirection == null
        ? null
        : axisDirectionToAxis(axisDirection);

    return _RawMKGap(value, color: color, fallbackDirection: fallbackDirection);
  }
}

class _RawMKGap extends LeafRenderObjectWidget {
  const _RawMKGap(this.value, {this.color, this.fallbackDirection})
    : assert(value >= 0);

  final num value;
  final Color? color;
  final Axis? fallbackDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMKGap(
      value: value,
      color: color,
      fallbackDirection: fallbackDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMKGap renderObject) {
    renderObject
      ..value = value
      ..color = color
      ..fallbackDirection = fallbackDirection;
  }
}

class _RenderMKGap extends RenderBox {
  _RenderMKGap({required num value, Color? color, Axis? fallbackDirection})
    : _value = value,
      _color = color,
      _fallbackDirection = fallbackDirection;

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

  Axis? get fallbackDirection => _fallbackDirection;
  Axis? _fallbackDirection;
  set fallbackDirection(Axis? value) {
    if (_fallbackDirection != value) {
      _fallbackDirection = value;
      markNeedsLayout();
    }
  }

  /// Mirrors `RenderGap._direction`: a [Gap] only knows its axis by
  /// inspecting its enclosing [RenderFlex] at layout time, since there's no
  /// inherited widget carrying that information down the widget tree.
  Axis? get _direction {
    final parentNode = parent;
    if (parentNode is RenderFlex) {
      return parentNode.direction;
    }
    return fallbackDirection;
  }

  double get _mainAxisExtent {
    switch (_direction) {
      case Axis.horizontal:
        return MKHelper().setWidth(_value);
      case Axis.vertical:
        return MKHelper().setHeight(_value);
      case null:
        return MKHelper().radius(_value);
    }
  }

  double? _computeIntrinsicExtent(Axis axis, double Function() compute) {
    if (_direction == axis) return _mainAxisExtent;
    return compute();
  }

  @override
  double computeMinIntrinsicWidth(double height) => _computeIntrinsicExtent(
    Axis.horizontal,
    () => super.computeMinIntrinsicWidth(height),
  )!;

  @override
  double computeMaxIntrinsicWidth(double height) => _computeIntrinsicExtent(
    Axis.horizontal,
    () => super.computeMaxIntrinsicWidth(height),
  )!;

  @override
  double computeMinIntrinsicHeight(double width) => _computeIntrinsicExtent(
    Axis.vertical,
    () => super.computeMinIntrinsicHeight(width),
  )!;

  @override
  double computeMaxIntrinsicHeight(double width) => _computeIntrinsicExtent(
    Axis.vertical,
    () => super.computeMaxIntrinsicHeight(width),
  )!;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final direction = _direction;
    if (direction == Axis.horizontal) {
      return constraints.constrain(Size(_mainAxisExtent, 0));
    } else if (direction == Axis.vertical) {
      return constraints.constrain(Size(0, _mainAxisExtent));
    }
    throw FlutterError(
      'An MKGap widget must be placed directly inside a Flex widget '
      'or its fallbackDirection must not be null',
    );
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (color != null) {
      final paint = Paint()..color = color!;
      context.canvas.drawRect(offset & size, paint);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('value', value.toDouble()));
    properties.add(DoubleProperty('mainAxisExtent', _mainAxisExtent));
    properties.add(ColorProperty('color', color));
    properties.add(EnumProperty<Axis>('fallbackDirection', fallbackDirection));
  }
}
