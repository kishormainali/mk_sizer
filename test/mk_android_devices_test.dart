import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer/mk_sizer.dart';

// Common Android logical sizes (dp), full window including system bars.
const devices = <String, Size>{
  'small 320x640': Size(320, 640),
  'galaxy a 360x800': Size(360, 800),
  'pixel 7 412x915': Size(412, 915),
  'fold inner 673x841': Size(673, 841),
  'tablet 800x1280': Size(800, 1280),
  'phone landscape 915x412': Size(915, 412),
  'tablet landscape 1280x800': Size(1280, 800),
};

Future<({double w, double h})> measure(
  WidgetTester t,
  Size device, {
  MKHeightMode mode = MKHeightMode.screen,
  double? min,
  double? max,
}) async {
  t.view.physicalSize = device;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  late ({double w, double h}) r;
  await t.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MKSizer(
        heightMode: mode,
        minScaleFactor: min,
        maxScaleFactor: max,
        builder: (c) {
          r = (w: 100.w, h: 100.h);
          return const SizedBox();
        },
      ),
    ),
  );
  return r;
}

void main() {
  for (final e in devices.entries) {
    testWidgets('clamps apply without respectAspectRatio: ${e.key}', (t) async {
      final r = await measure(t, e.value, min: 0.85, max: 1.3);
      for (final v in [r.w, r.h]) {
        expect(v, inInclusiveRange(85, 130));
      }
    });

    testWidgets('heightMode.width keeps h == w: ${e.key}', (t) async {
      final r = await measure(t, e.value, mode: MKHeightMode.width);
      expect(r.h, closeTo(r.w, 1e-9));
    });
  }

  testWidgets('tall phone: width mode removes vertical inflation', (t) async {
    final size = devices['pixel 7 412x915']!;
    final screen = await measure(t, size);
    expect(screen.h / screen.w, greaterThan(1.1));
    final uniform = await measure(t, size, mode: MKHeightMode.width);
    expect(uniform.h / uniform.w, closeTo(1, 1e-9));
  });

  testWidgets('safeArea subtracts system bars on a full-window MKSizer', (
    t,
  ) async {
    t.view.physicalSize = const Size(412, 915);
    t.view.devicePixelRatio = 1;
    t.view.viewPadding = const FakeViewPadding(top: 40, bottom: 35);
    addTearDown(t.view.reset);
    late double h;
    await t.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MKSizer(
          designSize: const Size(412, 840),
          heightMode: MKHeightMode.safeArea,
          builder: (c) {
            h = 840.h; // design height -> usable height
            return const SizedBox();
          },
        ),
      ),
    );
    expect(h, closeTo(915 - 75, 1e-9));
  });

  testWidgets('maxSystemTextScale caps OS font size inside MaterialApp', (
    t,
  ) async {
    t.view.physicalSize = const Size(412, 915);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(t.view.reset);
    addTearDown(t.platformDispatcher.clearAllTestValues);
    late double scale;
    await t.pumpWidget(
      MKSizer(
        maxSystemTextScale: 1.3,
        minSystemTextScale: 0.9,
        builder: (c) => MaterialApp(
          home: Builder(
            builder: (c) {
              scale = MediaQuery.textScalerOf(c).scale(10) / 10;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(scale, closeTo(1.3, 1e-9));
  });

  testWidgets('safeArea handles landscape cutout and live inset changes', (
    t,
  ) async {
    t.view.physicalSize = const Size(915, 412);
    t.view.devicePixelRatio = 1;
    t.view.viewPadding = const FakeViewPadding(left: 48, right: 0, bottom: 20);
    addTearDown(t.view.reset);
    late double w, h;
    Widget app() => Directionality(
      textDirection: TextDirection.ltr,
      child: MKSizer(
        designSize: const Size(100, 100),
        heightMode: MKHeightMode.safeArea,
        builder: (c) {
          w = 100.w;
          h = 100.h;
          return const SizedBox();
        },
      ),
    );
    await t.pumpWidget(app());
    expect([w, h], [915 - 48, 412 - 20]);

    // e.g. nav bar hidden: metrics change but constraints don't.
    t.view.viewPadding = FakeViewPadding.zero;
    await t.pump();
    expect([w, h], [915, 412]);
  });

  testWidgets('designPadding: design incl. bars maps to device incl. bars', (
    t,
  ) async {
    t.view.physicalSize = const Size(412, 915);
    t.view.devicePixelRatio = 1;
    t.view.viewPadding = const FakeViewPadding(top: 40, bottom: 35);
    addTearDown(t.view.reset);
    late double h;
    await t.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MKSizer(
          designSize: const Size(412, 915), // frame includes the bars
          designPadding: const EdgeInsets.only(top: 40, bottom: 35),
          heightMode: MKHeightMode.safeArea,
          builder: (c) {
            h = 840.h; // design's usable height == device's usable height
            return const SizedBox();
          },
        ),
      ),
    );
    expect(h, closeTo(840, 1e-9));
  });
}
