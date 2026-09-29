## 1.0.0

* Renamed the package to `mk_sizer` (import `package:mk_sizer/mk_sizer.dart`).
* Responsive sizing extensions: `.w`, `.h`, `.r`, `.sp`, `.pw`, `.ph`, spacing widgets and `EdgeInsets` helpers.
* Added `MKEdgeInsets` and `MKEdgeInsetsDirectional`; the directional variant scales horizontal values with `.w` and vertical with `.h`.
* `MKSizer.builder` is now a `WidgetBuilder`.
* Extensions no longer throw before `MKSizer` has built; they scale 1:1.
* Added `MKSizerModel` (an `InheritedModel`) and `context.w/h/r/sp/pw/ph`, which rebuild a widget only when the axis it uses changes and work inside `const` subtrees.
* `MKSizer.rebuildOnChange` (default `true`) rebuilds the subtree on size change so `10.w` is correct inside `const` widgets.
* Added tests.
