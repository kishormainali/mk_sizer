import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer/mk_sizer.dart';

Future<void> pump(
  WidgetTester tester,
  Size designSize,
  void Function() read, {
  Widget Function(Widget child)? wrap,
}) {
  final sizer = MKSizer(
    designSize: designSize,
    builder: (_) {
      read();
      return const SizedBox();
    },
  );
  return tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: tester.view.physicalSize / tester.view.devicePixelRatio,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: wrap == null ? sizer : wrap(sizer),
      ),
    ),
  );
}

void main() {
  // test surface is 800x600
  testWidgets('scales by width, height, min for radius, width for sp', (
    t,
  ) async {
    late double w, h, r, sp, pw, ph;
    await pump(t, const Size(100, 100), () {
      w = 10.w;
      h = 10.h;
      r = 10.r;
      sp = 10.sp;
      pw = 0.5.pw;
      ph = 0.5.ph;
    });
    expect([w, h, r, sp, pw, ph], [80, 60, 60, 80, 400, 300]);
  });

  testWidgets('identity at the design size (looks unchanged)', (t) async {
    late List<double> v;
    await pump(t, const Size(800, 600), () {
      v = [12.w, 12.h, 12.r, 12.sp, 12.5.w];
    });
    expect(v, [12, 12, 12, 12, 12.5]);
  });

  testWidgets('edge insets and spacing widgets use the right axis', (t) async {
    late MKEdgeInsets a;
    late MKEdgeInsetsDirectional d;
    late EdgeInsets ext;
    late SizedBox v, hs, vr;
    await pump(t, const Size(100, 100), () {
      a = MKEdgeInsets.fromLTRB(1, 2, 3, 4);
      d = MKEdgeInsetsDirectional.fromSTEB(1, 2, 3, 4);
      ext = const EdgeInsets.fromLTRB(1, 2, 3, 4).wh;
      v = 1.verticalSpace as SizedBox;
      hs = 1.horizontalSpace as SizedBox;
      vr = 1.verticalSpaceRadius as SizedBox;
    });
    // scaleW 8, scaleH 6
    expect([a.left, a.top, a.right, a.bottom], [8, 12, 24, 24]);
    expect([d.start, d.top, d.end, d.bottom], [8, 12, 24, 24]);
    expect([ext.left, ext.top, ext.right, ext.bottom], [8, 12, 24, 24]);
    expect([v.height, hs.width, vr.height], [6, 8, 6]);
    expect(MKEdgeInsets.all(1).left, 6);
    expect(MKEdgeInsets.symmetric(vertical: 1, horizontal: 1).horizontal, 16);
  });

  testWidgets('const MKPadding scales horizontal by .w and vertical by .h', (
    t,
  ) async {
    await t.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MKSizer(
            designSize: const Size(100, 100),
            builder: (_) => const MKPadding(
              padding: EdgeInsets.fromLTRB(1, 2, 3, 4),
              child: SizedBox(),
            ),
          ),
        ),
      ),
    );
    // scaleW 8, scaleH 6
    expect(
      t.renderObject<RenderPadding>(find.byType(MKPadding)).padding,
      const EdgeInsets.fromLTRB(8, 12, 24, 24),
    );
  });

  testWidgets('const MKSizedBox scales width by .w and height by .h', (
    t,
  ) async {
    await t.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MKSizer(
            designSize: const Size(100, 100),
            builder: (_) => const Center(
              child: MKSizedBox(width: 1, height: 1, child: Placeholder()),
            ),
          ),
        ),
      ),
    );
    // scaleW 8, scaleH 6
    expect(t.getSize(find.byType(MKSizedBox)), const Size(8, 6));
  });

  testWidgets('unbounded constraints fall back to screen size', (t) async {
    late double w;
    await pump(
      t,
      const Size(100, 100),
      () => w = 10.w,
      wrap: (c) =>
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: c),
    );
    expect(w.isFinite, true);
    expect(w, 80);
  });

  testWidgets('recomputes on resize', (t) async {
    late double w;
    await pump(t, const Size(100, 100), () => w = 10.w);
    expect(w, 80);
    t.view.physicalSize = const Size(1200, 1800);
    addTearDown(t.view.resetPhysicalSize);
    await pump(t, const Size(100, 100), () => w = 10.w);
    await t.pump();
    expect(w, 40);
  });

  testWidgets('recomputes on orientation change without re-pumping', (t) async {
    late double w, h;
    await pump(t, const Size(100, 100), () {
      w = 10.w;
      h = 10.h;
    });
    expect([w, h], [80, 60]);
    // landscape 800x600 -> portrait 600x800 (dpr 3)
    t.view.physicalSize = const Size(1800, 2400);
    addTearDown(t.view.resetPhysicalSize);
    await t.pump();
    expect([w, h], [60, 80]);
  });

  testWidgets('context sizing rebuilds only for its aspect, even in const', (
    t,
  ) async {
    _Probe.builds = 0;
    _Probe.last = 0;
    await t.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MKSizer(
            designSize: const Size(100, 100),
            rebuildOnChange: false,
            builder: (_) => const _Probe(),
          ),
        ),
      ),
    );
    expect([_Probe.builds, _Probe.last], [1, 80]);

    // height only changes: width dependent must not rebuild
    t.view.physicalSize = const Size(2400, 2700);
    addTearDown(t.view.resetPhysicalSize);
    await t.pump();
    expect(_Probe.builds, 1);

    // width changes: const child rebuilds with new value
    t.view.physicalSize = const Size(1800, 2700);
    await t.pump();
    expect([_Probe.builds, _Probe.last], [2, 60]);
  });

  testWidgets('10.w inside a const subtree updates on rotation', (t) async {
    _Ext.last = 0;
    await t.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MKSizer(
          designSize: const Size(100, 100),
          builder: (_) => const _Ext(),
        ),
      ),
    );
    expect(_Ext.last, 80);
    t.view.physicalSize = const Size(1800, 2400);
    addTearDown(t.view.resetPhysicalSize);
    await t.pump();
    expect(_Ext.last, 60);
  });

  testWidgets('context sizing without MKSizer throws in any mode', (t) async {
    await t.pumpWidget(
      Builder(
        builder: (c) {
          expect(() => c.w(1), throwsFlutterError);
          return const SizedBox();
        },
      ),
    );
  });
}

class _Ext extends StatelessWidget {
  const _Ext();
  static double last = 0;

  @override
  Widget build(BuildContext context) {
    last = 10.w;
    return const SizedBox();
  }
}

class _Probe extends StatelessWidget {
  const _Probe();
  static int builds = 0;
  static double last = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    last = context.w(10);
    return const SizedBox();
  }
}
