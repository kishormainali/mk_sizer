
## MK Sizer

MK Size helper created using concept of responsive_sizer and flutter_screen_util package.

## Installation
<hr/>
<br/>

```yaml
dependencies:
  mk_sizer: ^1.1.0
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
    10.gap,
    Text('Below'),
  ],
)
```

`10.gap` is a responsive [`Gap`](https://pub.dev/packages/gap)-like widget: it detects whether its parent `Flex` is a `Row` or `Column` and scales with `.w` or `.h` accordingly, so the same call works in either direction.

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
- `minScaleFactor` / `maxScaleFactor` clamp `.w`/`.h`/`.r` when `respectAspectRatio` is true.
- `minTextScaleFactor` / `maxTextScaleFactor` clamp `.sp` independently, regardless of `respectAspectRatio`.

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
- Sizes are recalculated whenever the available size changes (rotation, window resize), and the whole subtree rebuilds so `10.w` is correct everywhere, including `const` widgets.
- For fewer rebuilds, pass `rebuildOnChange: false` and use the context form (`context.w(20)`, `context.h(30)`, `context.sp(15)`); each widget then rebuilds only when its own axis changes. `10.w` is not tracked in that mode.
