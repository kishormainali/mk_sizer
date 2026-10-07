## 1.1.0

* Added `MKSizer.respectAspectRatio` (default `false`): blends the width/height scales toward their mean as the device's aspect ratio diverges from `designSize`'s, so layouts stretch less on very differently shaped screens (e.g. tablets vs. a phone mockup). No-op when the aspect ratios match.
* Added `MKSizer.minScaleFactor` / `maxScaleFactor` to clamp the `.w` / `.h` / `.r` scales (only when `respectAspectRatio` is true).
* Added `MKSizer.minTextScaleFactor` / `maxTextScaleFactor` to clamp the `.sp` scale independently of layout scales (applies regardless of `respectAspectRatio`). `context.sp` uses the same clamped scale.
* Added `MKResponsiveBuilder`, `MKDeviceType`, `context.deviceType` and `context.resValue(...)` for per-device-tier widgets/values (breakpoints 360 / 600 / 1024 by default).
* `MKHelper.changed` / `MKHelper.init` accept the new options; `MKSizerModel` notifies dependents correctly when they change.
* Added tests.

## 1.0.2

* Added `MKSizedBox`, a `const`-capable `SizedBox` that scales width with `.w` and height with `.h`.
* Added `MKPadding`, a `const`-capable `Padding` that scales horizontal insets with `.w` and vertical insets with `.h`, and updates on size change.

## 1.0.1

* Added `10.gap`: a responsive, axis-aware gap widget (`MKGap`) that scales with `.w` inside a `Row` and `.h` inside a `Column`, matching the main-axis detection used by `package:gap` but without depending on it.

## 1.0.0

* Renamed the package to `mk_sizer` (import `package:mk_sizer/mk_sizer.dart`).
* Responsive sizing extensions: `.w`, `.h`, `.r`, `.sp`, `.pw`, `.ph`, spacing widgets and `EdgeInsets` helpers.
* Added `MKEdgeInsets` and `MKEdgeInsetsDirectional`; the directional variant scales horizontal values with `.w` and vertical with `.h`.
* `MKSizer.builder` is now a `WidgetBuilder`.
* Extensions no longer throw before `MKSizer` has built; they scale 1:1.
* Added `MKSizerModel` (an `InheritedModel`) and `context.w/h/r/sp/pw/ph`, which rebuild a widget only when the axis it uses changes and work inside `const` subtrees.
* `MKSizer.rebuildOnChange` (default `true`) rebuilds the subtree on size change so `10.w` is correct inside `const` widgets.
* Added tests.
