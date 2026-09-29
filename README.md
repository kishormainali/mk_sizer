
## MK Sizer

MK Size helper created using concept of responsive_sizer and flutter_screen_util package.

## Installation
<hr/>
<br/>

```yaml
dependencies:
  mk_sizer: ^1.0.1
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

### Notes
<hr/>

- `.w`/`.h`/`.sp`/`.r` scale 1:1 until an `MKSizer` has laid out.
- `.sp` scales by width only; `.r` uses the smaller of the width/height scales.
- Default design size is `360x690`; pass `designSize:` to change it.
- Sizes are recalculated whenever the available size changes (rotation, window resize), and the whole subtree rebuilds so `10.w` is correct everywhere, including `const` widgets.
- For fewer rebuilds, pass `rebuildOnChange: false` and use the context form (`context.w(20)`, `context.h(30)`, `context.sp(15)`); each widget then rebuilds only when its own axis changes. `10.w` is not tracked in that mode.
