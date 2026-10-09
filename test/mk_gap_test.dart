import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer/mk_sizer.dart';

Future<void> pump(
  WidgetTester tester,
  Size deviceSize,
  Size designSize,
  Widget child,
) {
  tester.view.physicalSize = deviceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MKSizer(
        designSize: designSize,
        builder: (context) => Center(child: child),
      ),
    ),
  );
}

void main() {
  // design is square (100x100); device is 800x400, so scaleWidth=8,
  // scaleHeight=4.
  const designSize = Size(100, 100);
  const deviceSize = Size(800, 400);

  testWidgets('MKGap scales with width inside a Row', (tester) async {
    await pump(
      tester,
      deviceSize,
      designSize,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [const SizedBox(), MKGap(10), const SizedBox()],
      ),
    );

    final size = tester.getSize(find.byType(MKGap));
    expect(size.width, 80);
    expect(size.height, 0);
  });

  testWidgets('MKGap scales with height inside a Column', (tester) async {
    await pump(
      tester,
      deviceSize,
      designSize,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [const SizedBox(), MKGap(10), const SizedBox()],
      ),
    );

    final size = tester.getSize(find.byType(MKGap));
    expect(size.height, 40);
    expect(size.width, 0);
  });

  testWidgets('num.mkGap returns an MKGap scaled for its axis', (tester) async {
    await pump(
      tester,
      deviceSize,
      designSize,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [const SizedBox(), 10.mkGap, const SizedBox()],
      ),
    );

    final size = tester.getSize(find.byType(MKGap));
    expect(size.width, 80);
  });

  testWidgets('MKGap.expand fills the cross axis', (tester) async {
    await pump(
      tester,
      deviceSize,
      designSize,
      SizedBox(
        height: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const SizedBox(), MKGap.expand(10), const SizedBox()],
        ),
      ),
    );

    final size = tester.getSize(find.byType(MKGap));
    expect(size.width, 80);
    expect(size.height, 200);
  });

  testWidgets('MKGap.max takes at most its scaled value when space allows', (
    tester,
  ) async {
    await pump(
      tester,
      deviceSize,
      designSize,
      SizedBox(
        width: 500,
        child: Row(children: [MKGap.max(10), const SizedBox(width: 50)]),
      ),
    );

    final size = tester.getSize(find.byType(MKGap));
    expect(size.width, 80);
  });

  testWidgets('MKGap.max shrinks below its scaled value when space is tight', (
    tester,
  ) async {
    await pump(
      tester,
      deviceSize,
      designSize,
      SizedBox(
        width: 50,
        child: Row(children: [MKGap.max(10), const SizedBox(width: 50)]),
      ),
    );

    final size = tester.getSize(find.byType(MKGap));
    expect(size.width, 0);
  });
}
