import 'package:mk_sizer/mk_sizer.dart';
import 'package:flutter/material.dart';

/// A class that can be used to define edge insets with responsive insets.
class MKEdgeInsets extends EdgeInsets {
  /// Creates adapt insets from offsets from the left, top, right, and bottom.
  MKEdgeInsets.fromLTRB(double left, double top, double right, double bottom)
    : super.fromLTRB(left.w, top.h, right.w, bottom.h);

  /// Creates adapt insets where all the offsets are `value`.
  ///
  /// {@tool snippet}
  ///
  /// Adapt height-pixel margin on all sides:
  ///
  /// ```dart
  /// const MKEdgeInsets.all(8.0)
  /// ```
  /// {@end-tool}

  MKEdgeInsets.all(double value) : super.all(value.r);

  /// Creates adapt insets with only the given values non-zero.
  ///
  /// {@tool snippet}
  ///
  /// Adapt left margin indent of 40 pixels:
  ///
  /// ```dart
  /// const MKEdgeInsets.only(left: 40.0)
  /// ```
  /// {@end-tool}
  MKEdgeInsets.only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) : super.only(left: left.w, top: top.h, right: right.w, bottom: bottom.h);

  /// Creates adapt insets with symmetrical vertical and horizontal offsets.
  ///
  /// {@tool snippet}
  ///
  /// Adapt Eight pixel margin above and below, no horizontal margins:
  ///
  /// ```dart
  /// const MKEdgeInsets.symmetric(vertical: 8.0)
  /// ```
  /// {@end-tool}
  MKEdgeInsets.symmetric({double vertical = 0.0, double horizontal = 0.0})
    : super.symmetric(vertical: vertical.h, horizontal: horizontal.w);
}

/// A class that can be used to define edge insets in a directionally aware way.
class MKEdgeInsetsDirectional extends EdgeInsetsDirectional {
  /// Creates insets where all the offsets are `value`.
  ///
  /// {@tool snippet}
  ///
  /// Adapt eight-pixel margin on all sides:
  ///
  /// ```dart
  /// const MKEdgeInsetsDirectional.all(8.0)
  /// ```
  /// {@end-tool}
  MKEdgeInsetsDirectional.all(double value) : super.all(value.r);

  /// Creates insets with only the given values non-zero.
  ///
  /// {@tool snippet}
  ///
  /// Adapt margin indent of 40 pixels on the leading side:
  ///
  /// ```dart
  /// const MKEdgeInsetsDirectional.only(start: 40.0)
  /// ```
  /// {@end-tool}
  MKEdgeInsetsDirectional.only({
    double bottom = 0,
    double end = 0,
    double start = 0,
    double top = 0,
  }) : super.only(bottom: bottom.h, start: start.w, end: end.w, top: top.h);

  /// Creates adapt insets from offsets from the start, top, end, and bottom.
  MKEdgeInsetsDirectional.fromSTEB(
    double start,
    double top,
    double end,
    double bottom,
  ) : super.fromSTEB(start.w, top.h, end.w, bottom.h);
}
