
## MK Sizer

MK Size helper created using concept of responsive_sizer and flutter_screen_util package.

## Installation
<hr/>
<br/>

```yaml
dependencies:
  mk_sizer: ^1.4.0
```

## Usage

<hr/>
<br/>

### Import the package

```dart
import 'package:mk_sizer/mk_sizer.dart';
```

### Wrap MaterialApp with MKSizer widget
<hr/>
<br/>

```dart
MKSizer( 
  builder: (context) {
    return MaterialApp(
      home: HomePage(),
    );
  },
);
```

### Widget Size
<hr/>
<br/>

```dart
Container(
  width: 20.w,   
  height: 30.5.h     
)
```


### Text Size
<hr/>
<br/>

```dart
Text(
  'MK Sizer', 
  style: TextStyle(fontSize: 15.sp), 
)
```

### Gap
<hr/>
<br/>

```dart
Column(
  children: [
    Text('Above'),
    10.mkGap,
    Text('Below'),
  ],
)
```

`10.mkGap` is a responsive [`Gap`](https://pub.dev/packages/gap)-like widget: it detects whether its parent `Flex` is a `Row` or `Column` and scales with `.w` or `.h` accordingly, so the same call works in either direction. It's named `mkGap` rather than `gap` to avoid colliding with other packages' `num` extensions of the same name (e.g. `fp_extensions`, which depends on `package:gap`).

`MKGap` also mirrors `package:gap`'s full API: `MKGap.expand` fills the cross axis (like `Gap.expand`), `MKGap.max` takes at most its value and shrinks if the parent `Flex` runs out of room (like `MaxGap`), and `MKGap.maxExpand` combines both.

For sliver-based scroll views (`CustomScrollView` and friends), use `10.mkSliverGap` / `MKSliverGap(10)` — the sliver equivalent of `MKGap`, matching `package:gap`'s `SliverGap`. It scales with `.w` when the scroll view's axis is horizontal and `.h` when vertical.

### Aspect ratio and scale limits
<hr/>
<br/>

```dart
MKSizer(
  designSize: Size(430, 932),
  respectAspectRatio: true,
  minScaleFactor: 0.8,
  maxScaleFactor: 1.4,
  minTextScaleFactor: 0.9,
  maxTextScaleFactor: 1.1,
  builder: (context) => MaterialApp(home: HomePage()),
);
```

- `respectAspectRatio` blends the width/height scales toward each other as the device's aspect ratio diverges from `designSize`'s, so layouts stretch less on tablets. Default `false` (independent per-axis scaling).
- `minScaleFactor` / `maxScaleFactor` clamp `.w`/`.h`/`.r` (with or without `respectAspectRatio`), so tablets and foldables don't get 2-3x UI.
- `minTextScaleFactor` / `maxTextScaleFactor` clamp `.sp` independently, regardless of `respectAspectRatio`.

### flutter_screenutil compatibility
<hr/>
<br/>

```dart
MKSizer(
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context) => MaterialApp(home: HomePage()),
);
```

- `minTextAdapt` (default `false`): bases `.sp` on `min(scaleWidth, scaleHeight)` instead of `scaleWidth` alone, like `.r` does. Matches `flutter_screenutil`'s `ScreenUtil.init(minTextAdapt: true)` — use it when text shouldn't grow too large on screens that are wide but short.
- `splitScreenMode` (default `false`): floors the window height used for scaling at 700 logical pixels before computing `.h`/`.r`, so `.h` doesn't keep shrinking once a window (Android/iPad split-screen, desktop multi-window) goes below that height. `.w` is unaffected. Matches `flutter_screenutil`'s `splitScreenMode`, including its hardcoded 700px threshold.
- Both compose with `minScaleFactor`/`maxScaleFactor` and `respectAspectRatio` — they just change what feeds into the same scale pipeline.

### Android & consistent fonts
<hr/>
<br/>

```dart
MKSizer(
  heightMode: MKHeightMode.safeArea, // or MKHeightMode.width
  designSize: Size(430, 932),
  designPadding: EdgeInsets.only(top: 59, bottom: 34), // bars inside the frame
  minScaleFactor: 0.85,
  maxScaleFactor: 1.3,
  minTextScaleFactor: 0.9,
  maxTextScaleFactor: 1.1,
  minSystemTextScale: 0.9,
  maxSystemTextScale: 1.3,
  builder: (context) => MaterialApp(
    theme: ThemeData(fontFamily: 'Inter'), // same font on both platforms
    home: HomePage(),
  ),
);
```

- `heightMode`: tall Android phones (20:9+) inflate `.h` 15-30% over `.w`. `safeArea` subtracts system bars when `MKSizer` wraps the whole app; `width` makes `.h` use the width scale (never stretches vertically). Default `screen` is the original behavior. Design frames usually include the status bar/notch and home indicator, so with `safeArea` also pass `designPadding` (the bars inside your frame); then usable device area is compared with usable design area.
- `minSystemTextScale` / `maxSystemTextScale` clamp the user's OS font-size setting (Android allows ~2x, iOS less) for all text below `MKSizer`, including inside `MaterialApp`. `minTextScaleFactor` / `maxTextScaleFactor` clamp `.sp` (screen-size scaling); the two multiply.
- Fonts differ because Android defaults to Roboto and iOS to SF. Bundle one `fontFamily` in your theme for identical glyph widths and line heights.

### Responsive builder
<hr/>
<br/>

```dart
MKResponsiveBuilder(
  mobile: (context) => MobileLayout(),
  tablet: (context) => TabletLayout(),
);

final padding = context.resValue(mobile: 16.0, tablet: 24.0, desktop: 32.0);
```

Tiers come from the `MediaQuery` width (`smallMobile` < 360 <= `mobile` < 600 <= `tablet` < 1024 <= `desktop`); missing tiers fall back to the next-smaller one, ultimately `mobile`.

### Notes
<hr/>

- `.w`/`.h`/`.sp`/`.r` scale 1:1 until an `MKSizer` has laid out.
- `.sp` scales by width only; `.r` uses the smaller of the width/height scales.
- Default design size is `360x690`; pass `designSize:` to change it.
- Use your Figma/XD frame's `px` dimensions directly as `designSize` — no conversion needed. Figma's `px` is the CSS reference pixel (96 DPI), the same unit as Flutter's logical pixels (and `MediaQuery.sizeOf`'s values), which is also what Android `dp` and iOS points resolve to. A `1x` export of a 1x frame is therefore already in the right unit.
- Sizes are recalculated whenever the available size changes (rotation, window resize), and the whole subtree rebuilds so `10.w` is correct everywhere, including `const` widgets.
- For fewer rebuilds, pass `rebuildOnChange: false` and use the context form (`context.w(20)`, `context.h(30)`, `context.sp(15)`); each widget then rebuilds only when its own axis changes. `10.w` is not tracked in that mode.
