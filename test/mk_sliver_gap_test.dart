import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer/mk_sizer.dart';

Future<void> pump(
  WidgetTester tester,
  Size deviceSize,
  Size designSize,
  Widget sliver, {
  Axis scrollDirection = Axis.vertical,
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
        builder: (context) => CustomScrollView(
          scrollDirection: scrollDirection,
          slivers: [
            SliverToBoxAdapter(child: SizedBox.shrink()),
            sliver,
            SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
    ),
  );
}

void main() {
  // design is square (100x100); device is 800x400, so scaleWidth=8,
  // scaleHeight=4.
  const designSize = Size(100, 100);
  const deviceSize = Size(800, 400);

  testWidgets('MKSliverGap scales with height in a vertical scroll view', (
    tester,
  ) async {
    await pump(tester, deviceSize, designSize, MKSliverGap(10));

    final renderGap = tester.renderObject<MKRenderSliverGap>(
      find.byType(MKSliverGap),
    );
    expect(renderGap.geometry!.scrollExtent, 40);
  });

  testWidgets('MKSliverGap scales with width in a horizontal scroll view', (
    tester,
  ) async {
    await pump(
      tester,
      deviceSize,
      designSize,
      MKSliverGap(10),
      scrollDirection: Axis.horizontal,
    );

    final renderGap = tester.renderObject<MKRenderSliverGap>(
      find.byType(MKSliverGap),
    );
    expect(renderGap.geometry!.scrollExtent, 80);
  });

  testWidgets('num.mkSliverGap returns an MKSliverGap scaled for its axis', (
    tester,
  ) async {
    await pump(tester, deviceSize, designSize, 10.mkSliverGap);

    final renderGap = tester.renderObject<MKRenderSliverGap>(
      find.byType(MKSliverGap),
    );
    expect(renderGap.geometry!.scrollExtent, 40);
  });
}
