/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */

part of 'mk_widget.dart';

/// A responsive equivalent of `package:gap`'s `Gap` widget: it takes a fixed
/// amount of space in the direction of its parent [Flex] (or [Scrollable]),
/// scaling [value] with [MKHelper.setWidth] when that direction is
/// horizontal and [MKHelper.setHeight] when vertical, so the same `10.mkGap`
/// call is correct inside both a [Row] and a [Column].
///
/// It only works in the following cases:
/// - It is a descendant of a [Row], [Column], or [Flex], and the path from
/// this widget to its enclosing [Flex] must contain only
/// [StatelessWidget]s or [StatefulWidget]s (not other kinds of widgets,
/// like [RenderObjectWidget]s).
/// - It is a descendant of a [Scrollable].
///
/// Mirrors `package:gap`'s full API surface:
/// - [MKGap.expand] matches `Gap.expand`: the gap fills the cross axis.
/// - [MKGap.max] matches `MaxGap`: the gap takes, at most, [value] of space,
/// shrinking if the parent [Flex] doesn't have enough room.
/// - [MKGap.maxExpand] combines both.
class MKGap extends StatelessWidget {
  /// Creates a widget that takes a responsive amount of space in the
  /// direction of its parent.
  ///
  /// [crossAxisExtent], if given, is scaled on the opposite axis (e.g. with
  /// [MKHelper.setHeight] when the parent is a [Row]) and defaults to `0`,
  /// matching `package:gap`'s `Gap`.
  const MKGap(this.value, {super.key, this.crossAxisExtent, this.color})
    : assert(
        value >= 0 && value < double.infinity,
        'value must be positive and finite',
      ),
      assert(
        crossAxisExtent == null || crossAxisExtent >= 0,
        'crossAxisExtent must be positive',
      ),
      _flex = false;

  /// Creates a gap that takes a responsive [value] of space in the main
  /// axis and expands to fill the cross axis, matching `Gap.expand`.
  const MKGap.expand(this.value, {super.key, this.color})
    : assert(
        value >= 0 && value < double.infinity,
        'value must be positive and finite',
      ),
      crossAxisExtent = double.infinity,
      _flex = false;

  /// Creates a gap that takes, at most, a responsive [value] of space in
  /// the main axis, shrinking if its parent [Flex] doesn't have enough
  /// room, matching `MaxGap`.
  const MKGap.max(this.value, {super.key, this.crossAxisExtent, this.color})
    : assert(
        value >= 0 && value < double.infinity,
        'value must be positive and finite',
      ),
      assert(
        crossAxisExtent == null || crossAxisExtent >= 0,
        'crossAxisExtent must be positive',
      ),
      _flex = true;

  /// Creates a gap that takes, at most, a responsive [value] of space in
  /// the main axis and expands to fill the cross axis, matching
  /// `MaxGap.expand`.
  const MKGap.maxExpand(this.value, {super.key, this.color})
    : assert(
        value >= 0 && value < double.infinity,
        'value must be positive and finite',
      ),
      crossAxisExtent = double.infinity,
      _flex = true;

  /// Design-space main-axis size; scaled by [MKHelper] depending on the
  /// detected axis.
  final num value;

  /// Design-space cross-axis size; scaled by [MKHelper] on the opposite
  /// axis. `null` defaults to `0`; [double.infinity] expands to fill the
  /// cross axis (see [MKGap.expand]).
  final num? crossAxisExtent;

  /// The color used to fill the gap.
  final Color? color;

  /// Whether this gap is wrapped in a [Flexible], taking, at most, [value]
  /// of space (see [MKGap.max]).
  final bool _flex;

  @override
  Widget build(BuildContext context) {
    if (_flex) {
      return Flexible(
        child: _RawMKGap(value, crossAxisExtent: crossAxisExtent, color: color),
      );
    }

    final scrollableState = Scrollable.maybeOf(context);
    final axisDirection = scrollableState?.axisDirection;
    final fallbackDirection = axisDirection == null
        ? null
        : axisDirectionToAxis(axisDirection);

    return _RawMKGap(
      value,
      crossAxisExtent: crossAxisExtent,
      color: color,
      fallbackDirection: fallbackDirection,
    );
  }
}

class _RawMKGap extends LeafRenderObjectWidget {
  const _RawMKGap(
    this.value, {
    this.crossAxisExtent,
    this.color,
    this.fallbackDirection,
  }) : assert(value >= 0 && value < double.infinity),
       assert(crossAxisExtent == null || crossAxisExtent >= 0);

  final num value;
  final num? crossAxisExtent;
  final Color? color;
  final Axis? fallbackDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMKGap(
      value: value,
      crossAxisExtent: crossAxisExtent ?? 0,
      color: color,
      fallbackDirection: fallbackDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMKGap renderObject) {
    renderObject
      ..value = value
      ..crossAxisExtent = crossAxisExtent ?? 0
      ..color = color
      ..fallbackDirection = fallbackDirection;
  }
}

class _RenderMKGap extends RenderBox {
  _RenderMKGap({
    required num value,
    required num crossAxisExtent,
    Color? color,
    Axis? fallbackDirection,
  }) : _value = value,
       _crossAxisExtent = crossAxisExtent,
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

  num get crossAxisExtent => _crossAxisExtent;
  num _crossAxisExtent;
  set crossAxisExtent(num value) {
    if (_crossAxisExtent != value) {
      _crossAxisExtent = value;
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

  /// Mirrors `RenderGap._direction`: a [MKGap] only knows its axis by
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

  double get _resolvedCrossAxisExtent {
    if (_crossAxisExtent.isInfinite) return double.infinity;
    switch (_direction) {
      case Axis.horizontal:
        return MKHelper().setHeight(_crossAxisExtent);
      case Axis.vertical:
        return MKHelper().setWidth(_crossAxisExtent);
      case null:
        return MKHelper().radius(_crossAxisExtent);
    }
  }

  double? _computeIntrinsicExtent(Axis axis, double Function() compute) {
    if (_direction == axis) return _mainAxisExtent;
    final crossAxisExtent = _resolvedCrossAxisExtent;
    if (crossAxisExtent.isFinite) return crossAxisExtent;
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
      return constraints.constrain(
        Size(_mainAxisExtent, _resolvedCrossAxisExtent),
      );
    } else if (direction == Axis.vertical) {
      return constraints.constrain(
        Size(_resolvedCrossAxisExtent, _mainAxisExtent),
      );
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
    properties.add(DoubleProperty('mainAxisExtent', _mainAxisExtent));
    properties.add(
      DoubleProperty('crossAxisExtent', _resolvedCrossAxisExtent),
    );
    properties.add(ColorProperty('color', color));
    properties.add(EnumProperty<Axis>('fallbackDirection', fallbackDirection));
  }
}
