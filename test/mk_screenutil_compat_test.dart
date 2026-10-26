import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer/mk_sizer.dart';

Future<void> pump(
  WidgetTester tester,
  Size deviceSize,
  Size designSize,
  void Function(BuildContext context) read, {
  bool minTextAdapt = false,
  bool splitScreenMode = false,
  double? minScaleFactor,
  double? maxScaleFactor,
}) {
  tester.view.physicalSize = deviceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MKSizer(
        designSize: designSize,
        minTextAdapt: minTextAdapt,
        splitScreenMode: splitScreenMode,
        minScaleFactor: minScaleFactor,
        maxScaleFactor: maxScaleFactor,
        builder: (context) {
          read(context);
          return const SizedBox();
        },
      ),
    ),
  );
}

void main() {
  group('minTextAdapt', () {
    // design is square (100x100); device is a wide 800x400, so raw
    // scaleWidth=8, scaleHeight=4.
    const designSize = Size(100, 100);
    const deviceSize = Size(800, 400);

    testWidgets('defaults to false: .sp scales with width only', (t) async {
      late double w, sp;
      await pump(t, deviceSize, designSize, (c) {
        w = 10.w;
        sp = 10.sp;
      });
      expect([w, sp], [80, 80]);
    });

    testWidgets('true: .sp uses the smaller of width/height scales', (
      t,
    ) async {
      late double w, h, sp;
      await pump(
        t,
        deviceSize,
        designSize,
        (c) {
          w = 10.w;
          h = 10.h;
          sp = 10.sp;
        },
        minTextAdapt: true,
      );
      expect([w, h, sp], [80, 40, 40]);
    });

    testWidgets('true: context.sp sees the same min-based scale', (t) async {
      late double sp;
      await pump(
        t,
        deviceSize,
        designSize,
        (c) => sp = c.sp(10),
        minTextAdapt: true,
      );
      expect(sp, 40);
    });
  });

  group('splitScreenMode', () {
    const designSize = Size(360, 690);

    testWidgets('defaults to false: short window keeps shrinking .h', (
      t,
    ) async {
      late double h;
      // a 360x400 split-screen window: raw scaleHeight = 400/690.
      await pump(t, const Size(360, 400), designSize, (c) {
        h = 690.h;
      });
      expect(h, closeTo(400, 0.001));
    });

    testWidgets('true: height floors at 700 below that window height', (
      t,
    ) async {
      late double h;
      // window height (400) is below the 700 floor, so scaleHeight is
      // pinned at 700/690 instead of 400/690.
      await pump(t, const Size(360, 400), designSize, (c) {
        h = 690.h;
      }, splitScreenMode: true);
      expect(h, closeTo(700, 0.001));
    });

    testWidgets('true: no-op once the window is taller than the floor', (
      t,
    ) async {
      late double h;
      await pump(t, const Size(360, 932), designSize, (c) {
        h = 690.h;
      }, splitScreenMode: true);
      expect(h, closeTo(932, 0.001));
    });

    testWidgets('true: minScaleFactor/maxScaleFactor still clamp the result', (
      t,
    ) async {
      late double h;
      await pump(t, const Size(360, 400), designSize, (c) {
        h = 690.h;
      }, splitScreenMode: true, maxScaleFactor: 0.9);
      // floored scale (700/690 ~= 1.0145) still gets capped to 0.9.
      expect(h, closeTo(621, 0.001));
    });
  });
}
