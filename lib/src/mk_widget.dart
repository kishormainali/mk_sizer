/*
 * Copyright (c) 2022.
 * Author: Kishor Mainali
 * Company: EB Pearls
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'mk_extension.dart';
part 'mk_gap.dart';
part 'mk_helper.dart';
part 'mk_model.dart';
part 'mk_padding.dart';
part 'mk_responsive_builder.dart';
part 'mk_sized_box.dart';

class MKSizer extends StatelessWidget {
  const MKSizer({
    super.key,
    required this.builder,
    this.designSize = MKHelper.defaultSize,
    this.rebuildOnChange = true,
    this.respectAspectRatio = false,
    this.minScaleFactor,
    this.maxScaleFactor,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  });

  final WidgetBuilder builder;

  /// Size of the design (Figma/XD) the dimensions are based on.
  final Size designSize;

  /// Rebuilds the whole subtree when the size changes (rotation, resize), so
  /// `10.w` stays correct even inside `const` widgets. Set to `false` if you
  /// only use `context.w(10)` and want widgets to rebuild only for the axis
  /// they use.
  final bool rebuildOnChange;

  /// When true, blends `.w`/`.h` (and anything derived from them, like `.r`
  /// and `.sp`) toward each other as the device's aspect ratio diverges from
  /// [designSize]'s, instead of scaling each axis fully independently. This
  /// avoids stretched layouts on screens shaped very differently from the
  /// design (e.g. a wide tablet vs. a narrow phone mockup). A device whose
  /// aspect ratio matches [designSize] exactly is unaffected either way.
  /// Defaults to `false` to preserve the original per-axis scaling.
  final bool respectAspectRatio;

  /// Lower bound applied to the blended scale when [respectAspectRatio] is
  /// true. Has no effect otherwise.
  final double? minScaleFactor;

  /// Upper bound applied to the blended scale when [respectAspectRatio] is
  /// true. Has no effect otherwise.
  final double? maxScaleFactor;

  /// Lower bound applied to `.sp`'s scale, independent of [minScaleFactor]/
  /// [maxScaleFactor] (and applied regardless of [respectAspectRatio]). Use
  /// this to keep text sizing more uniform across devices than layout
  /// dimensions, e.g. `minTextScaleFactor: 0.9, maxTextScaleFactor: 1.1`.
  final double? minTextScaleFactor;

  /// Upper bound applied to `.sp`'s scale. See [minTextScaleFactor].
  final double? maxTextScaleFactor;

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
        final changed = MKHelper.changed(
          size,
          designSize,
          respectAspectRatio: respectAspectRatio,
          minScaleFactor: minScaleFactor,
          maxScaleFactor: maxScaleFactor,
          minTextScaleFactor: minTextScaleFactor,
          maxTextScaleFactor: maxTextScaleFactor,
        );
        MKHelper.init(
          size: size,
          designSize: designSize,
          respectAspectRatio: respectAspectRatio,
          minScaleFactor: minScaleFactor,
          maxScaleFactor: maxScaleFactor,
          minTextScaleFactor: minTextScaleFactor,
          maxTextScaleFactor: maxTextScaleFactor,
        );
        if (rebuildOnChange && changed) _markSubtreeDirty(context as Element);
        return MKSizerModel(
          size: size,
          designSize: designSize,
          respectAspectRatio: respectAspectRatio,
          minScaleFactor: minScaleFactor,
          maxScaleFactor: maxScaleFactor,
          minTextScaleFactor: minTextScaleFactor,
          maxTextScaleFactor: maxTextScaleFactor,
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
