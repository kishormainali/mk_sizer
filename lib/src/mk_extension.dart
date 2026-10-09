/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */

part of 'mk_widget.dart';

extension MKSizeExt on num {
  double get w => MKHelper().setWidth(this);

  double get h => MKHelper().setHeight(this);

  double get r => MKHelper().radius(this);

  double get pw => MKHelper().width * this;

  double get ph => MKHelper().height * this;

  double get sp => MKHelper().setSp(this);

  Widget get verticalSpace => MKHelper().setVerticalSpacing(this);

  Widget get verticalSpaceRadius => MKHelper().setVerticalSpacingRadius(this);

  Widget get horizontalSpace => MKHelper().setHorizontalSpacing(this);

  Widget get horizontalSpaceRadius =>
      MKHelper().setHorizontalSpacingRadius(this);

  /// A responsive gap (see [MKGap]) that fits itself to the direction of
  /// its parent `Row`/`Column`, e.g. `10.mkGap`.
  ///
  /// Named `mkGap` rather than `gap` to avoid colliding with `num` gap
  /// extensions from other packages (e.g. `fp_extensions`, which depends on
  /// `package:gap`).
  Widget get mkGap => MKGap(this);

  /// A responsive sliver gap (see [MKSliverGap]) for use inside a
  /// [CustomScrollView] or other sliver-based scroll view, e.g.
  /// `10.mkSliverGap`.
  Widget get mkSliverGap => MKSliverGap(this);
}

extension MKEdgeInsetsX on EdgeInsets {
  EdgeInsets get r => EdgeInsets.fromLTRB(left.r, top.r, right.r, bottom.r);

  EdgeInsets get w => EdgeInsets.fromLTRB(left.w, top.w, right.w, bottom.w);

  EdgeInsets get h => EdgeInsets.fromLTRB(left.h, top.h, right.h, bottom.h);

  EdgeInsets get wh => EdgeInsets.fromLTRB(left.w, top.h, right.w, bottom.h);
}
