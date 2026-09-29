/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'mk_helper.dart';
part 'mk_extension.dart';
part 'mk_model.dart';
part 'mk_gap.dart';

class MKSizer extends StatelessWidget {
  const MKSizer({
    super.key,
    required this.builder,
    this.designSize = MKHelper.defaultSize,
    this.rebuildOnChange = true,
  });

  final WidgetBuilder builder;

  /// Size of the design (Figma/XD) the dimensions are based on.
  final Size designSize;

  /// Rebuilds the whole subtree when the size changes (rotation, resize), so
  /// `10.w` stays correct even inside `const` widgets. Set to `false` if you
  /// only use `context.w(10)` and want widgets to rebuild only for the axis
  /// they use.
  final bool rebuildOnChange;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Unbounded constraints (e.g. inside a scroll view) would give infinite
        // scales, so fall back to the screen size on that axis.
        final bounded =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        final screen = bounded ? Size.zero : MediaQuery.sizeOf(context);
        final size = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : screen.width,
          constraints.hasBoundedHeight ? constraints.maxHeight : screen.height,
        );
        final changed = MKHelper.changed(size, designSize);
        MKHelper.init(size: size, designSize: designSize);
        if (rebuildOnChange && changed) _markSubtreeDirty(context as Element);
        return MKSizerModel(
          size: size,
          designSize: designSize,
          child: Builder(builder: builder),
        );
      },
    );
  }
}

void _markSubtreeDirty(Element element) {
  element.visitChildren((child) {
    child.markNeedsBuild();
    _markSubtreeDirty(child);
  });
}
