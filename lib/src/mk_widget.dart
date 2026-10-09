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
    this.heightMode = MKHeightMode.screen,
    this.designPadding = EdgeInsets.zero,
    this.minSystemTextScale,
    this.maxSystemTextScale,
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

  /// How `.h` is derived. Tall Android phones inflate `.h` relative to `.w`
  /// by 15-30% with the default [MKHeightMode.screen]; use
  /// [MKHeightMode.safeArea] or [MKHeightMode.width] to tame that.
  final MKHeightMode heightMode;

  /// System UI the [designSize] frame includes (status bar + notch at the top,
  /// home indicator / nav bar at the bottom, landscape cutouts at the sides).
  /// Only used with [MKHeightMode.safeArea], where the device's bars are
  /// subtracted: subtracting the design's bars too compares usable area with
  /// usable area. E.g. a 430x932 iPhone frame:
  /// `EdgeInsets.only(top: 59, bottom: 34)`. Leave at zero if the frame
  /// excludes the bars.
  final EdgeInsets designPadding;

  /// Clamp for the user's system font size setting (Android "Font size" /
  /// iOS "Text size"), applied to all descendant text via `MediaQuery`.
  /// This is separate from `.sp`: `.sp` adapts to the screen, this limits
  /// how far the OS accessibility scale can push text. Android allows up to
  /// ~2x (non-linear since Android 14) so a cap like `1.3` keeps layouts
  /// consistent with iOS. `null` leaves the system scale untouched.
  final double? minSystemTextScale;

  /// Upper bound for the system font scale. See [minSystemTextScale].
  final double? maxSystemTextScale;

  @override
  Widget build(BuildContext context) {
    Widget layout() => LayoutBuilder(
      builder: (context, constraints) {
        // Unbounded constraints (e.g. inside a scroll view) would give infinite
        // scales, so fall back to the screen size on that axis.
        final bounded =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        final screen = bounded ? Size.zero : MediaQuery.sizeOf(context);
        var size = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : screen.width,
          constraints.hasBoundedHeight ? constraints.maxHeight : screen.height,
        );
        if (heightMode == MKHeightMode.safeArea) {
          // Only when spanning the whole window; below a Scaffold the system
          // bars are already excluded from the constraints.
          final view = View.of(context);
          final ratio = view.devicePixelRatio;
          final pad = view.viewPadding;
          final full = view.physicalSize / ratio;
          // viewPadding = notch/cutout + status bar + nav bar, unaffected by
          // the keyboard. Left/right matter for landscape cutouts.
          size = Size(
            size.width >= full.width - 0.5
                ? max(size.width - (pad.left + pad.right) / ratio, 1)
                : size.width,
            size.height >= full.height - 0.5
                ? max(size.height - (pad.top + pad.bottom) / ratio, 1)
                : size.height,
          );
        }
        final designSize = heightMode == MKHeightMode.safeArea
            ? Size(
                max(this.designSize.width - designPadding.horizontal, 1),
                max(this.designSize.height - designPadding.vertical, 1),
              )
            : this.designSize;
        final heightFromWidth = heightMode == MKHeightMode.width;
        final changed = MKHelper.changed(
          size,
          designSize,
          respectAspectRatio: respectAspectRatio,
          minScaleFactor: minScaleFactor,
          maxScaleFactor: maxScaleFactor,
          minTextScaleFactor: minTextScaleFactor,
          maxTextScaleFactor: maxTextScaleFactor,
          heightFromWidth: heightFromWidth,
        );
        MKHelper.init(
          size: size,
          designSize: designSize,
          respectAspectRatio: respectAspectRatio,
          minScaleFactor: minScaleFactor,
          maxScaleFactor: maxScaleFactor,
          minTextScaleFactor: minTextScaleFactor,
          maxTextScaleFactor: maxTextScaleFactor,
          heightFromWidth: heightFromWidth,
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
          heightFromWidth: heightFromWidth,
          child: _clampSystemText(context, Builder(builder: builder)),
        );
      },
    );
    // Insets change without the constraints changing (status bar hidden,
    // gesture/3-button nav switched), so safeArea must re-measure on metrics.
    return heightMode == MKHeightMode.safeArea
        ? _MetricsRebuilder(builder: layout)
        : layout();
  }
}

class _MetricsRebuilder extends StatefulWidget {
  const _MetricsRebuilder({required this.builder});

  final Widget Function() builder;

  @override
  State<_MetricsRebuilder> createState() => _MetricsRebuilderState();
}

class _MetricsRebuilderState extends State<_MetricsRebuilder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder();
}

extension on MKSizer {
  Widget _clampSystemText(BuildContext context, Widget child) {
    if (minSystemTextScale == null && maxSystemTextScale == null) return child;
    // MKSizer usually sits above MaterialApp, where there is no MediaQuery yet.
    final data =
        MediaQuery.maybeOf(context) ??
        MediaQueryData.fromView(View.of(context));
    return MediaQuery(
      data: data.copyWith(
        textScaler: data.textScaler.clamp(
          minScaleFactor: minSystemTextScale ?? 0,
          maxScaleFactor: maxSystemTextScale ?? double.infinity,
        ),
      ),
      child: child,
    );
  }
}

void _markSubtreeDirty(Element element) {
  element.visitChildren((child) {
    child.markNeedsBuild();
    _markSubtreeDirty(child);
  });
}
