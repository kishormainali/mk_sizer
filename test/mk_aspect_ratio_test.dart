import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer/mk_sizer.dart';

Future<void> pump(
  WidgetTester tester,
  Size deviceSize,
  Size designSize,
  void Function(BuildContext context) read, {
  bool respectAspectRatio = false,
  double? minScaleFactor,
  double? maxScaleFactor,
  double? minTextScaleFactor,
  double? maxTextScaleFactor,
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
        respectAspectRatio: respectAspectRatio,
        minScaleFactor: minScaleFactor,
        maxScaleFactor: maxScaleFactor,
        minTextScaleFactor: minTextScaleFactor,
        maxTextScaleFactor: maxTextScaleFactor,
        builder: (context) {
          read(context);
          return const SizedBox();
        },
      ),
    ),
  );
}

void main() {
  // design is square (100x100); device is a wide 800x400 (aspect 2.0),
  // so raw scaleWidth=8, scaleHeight=4.
  const designSize = Size(100, 100);
  const deviceSize = Size(800, 400);

  testWidgets('respectAspectRatio defaults to false: raw independent scale', (
    t,
  ) async {
    late double w, h;
    await pump(t, deviceSize, designSize, (c) {
      w = 10.w;
      h = 10.h;
    });
    expect([w, h], [80, 40]);
  });

  testWidgets('respectAspectRatio true blends width/height toward their mean', (
    t,
  ) async {
    late double w, h;
    await pump(t, deviceSize, designSize, (c) {
      w = 10.w;
      h = 10.h;
    }, respectAspectRatio: true);
    // ratio = min(2,1)/max(2,1) = 0.5, blend = 0.5, mean = 6
    // scaleWidth = 8 + (6-8)*0.5 = 7, scaleHeight = 4 + (6-4)*0.5 = 5
    expect([w, h], [70, 50]);
  });

  testWidgets('blend is a no-op when device aspect matches design aspect', (
    t,
  ) async {
    late double w, h;
    // device (400x200) has the same 2.0 aspect ratio as itself scaled;
    // use a design with matching aspect ratio so raw scaleWidth==scaleHeight.
    await pump(t, const Size(400, 200), const Size(200, 100), (c) {
      w = 10.w;
      h = 10.h;
    }, respectAspectRatio: true);
    expect([w, h], [20, 20]);
  });

  testWidgets('maxScaleFactor clamps the blended scale when enabled', (
    t,
  ) async {
    late double w, h;
    await pump(
      t,
      deviceSize,
      designSize,
      (c) {
        w = 10.w;
        h = 10.h;
      },
      respectAspectRatio: true,
      maxScaleFactor: 6,
    );
    // scaleWidth clamps from 7 to 6; scaleHeight (5) is under the cap.
    expect([w, h], [60, 50]);
  });

  testWidgets('minScaleFactor clamps the blended scale when enabled', (
    t,
  ) async {
    late double w, h;
    await pump(
      t,
      deviceSize,
      designSize,
      (c) {
        w = 10.w;
        h = 10.h;
      },
      respectAspectRatio: true,
      minScaleFactor: 5.5,
    );
    // scaleHeight clamps from 5 up to 5.5; scaleWidth (7) is above the floor.
    expect([w, h], [70, 55]);
  });

  testWidgets(
    'min/maxScaleFactor have no effect when respectAspectRatio is false',
    (t) async {
      late double w, h;
      await pump(
        t,
        deviceSize,
        designSize,
        (c) {
          w = 10.w;
          h = 10.h;
        },
        minScaleFactor: 5.5,
        maxScaleFactor: 6,
      );
      expect([w, h], [80, 40]);
    },
  );

  testWidgets('context.w/context.h see the same blended scale', (t) async {
    late double w, h;
    await pump(t, deviceSize, designSize, (c) {
      w = c.w(10);
      h = c.h(10);
    }, respectAspectRatio: true);
    expect([w, h], [70, 50]);
  });

  group('text scale clamp', () {
    testWidgets('minTextScaleFactor clamps .sp independently of width', (
      t,
    ) async {
      late double w, sp;
      await pump(
        t,
        deviceSize,
        designSize,
        (c) {
          w = 10.w;
          sp = 10.sp;
        },
        respectAspectRatio: true,
        minTextScaleFactor: 7.5,
      );
      // scaleWidth stays 7 (blended, unclamped by layout bounds); text
      // floors separately at 7.5.
      expect([w, sp], [70, 75]);
    });

    testWidgets('maxTextScaleFactor clamps .sp independently of width', (
      t,
    ) async {
      late double w, sp;
      await pump(
        t,
        deviceSize,
        designSize,
        (c) {
          w = 10.w;
          sp = 10.sp;
        },
        respectAspectRatio: true,
        maxTextScaleFactor: 6.5,
      );
      expect([w, sp], [70, 65]);
    });

    testWidgets('text clamp applies even when respectAspectRatio is false', (
      t,
    ) async {
      late double w, sp;
      await pump(t, deviceSize, designSize, (c) {
        w = 10.w;
        sp = 10.sp;
      }, maxTextScaleFactor: 7);
      // raw scaleWidth is 8; layout stays unclamped, text clamps to 7.
      expect([w, sp], [80, 70]);
    });

    testWidgets('context.sp sees the same clamped text scale', (t) async {
      late double sp;
      await pump(
        t,
        deviceSize,
        designSize,
        (c) => sp = c.sp(10),
        respectAspectRatio: true,
        maxTextScaleFactor: 6.5,
      );
      expect(sp, 65);
    });
  });
}
