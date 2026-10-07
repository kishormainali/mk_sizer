import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer/mk_sizer.dart';

Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('MKResponsiveBuilder', () {
    testWidgets('renders smallMobile below 360', (t) async {
      await pumpAt(
        t,
        const Size(300, 800),
        MKResponsiveBuilder(
          smallMobile: (_) => const Text('smallMobile'),
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
          desktop: (_) => const Text('desktop'),
        ),
      );
      expect(find.text('smallMobile'), findsOneWidget);
    });

    testWidgets('renders mobile between 360 and 599', (t) async {
      await pumpAt(
        t,
        const Size(400, 800),
        MKResponsiveBuilder(
          smallMobile: (_) => const Text('smallMobile'),
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
          desktop: (_) => const Text('desktop'),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('renders tablet between 600 and 1023', (t) async {
      await pumpAt(
        t,
        const Size(700, 800),
        MKResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
          desktop: (_) => const Text('desktop'),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('renders desktop at or above 1024', (t) async {
      await pumpAt(
        t,
        const Size(1200, 800),
        MKResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
          desktop: (_) => const Text('desktop'),
        ),
      );
      expect(find.text('desktop'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet is unset', (t) async {
      await pumpAt(
        t,
        const Size(700, 800),
        MKResponsiveBuilder(mobile: (_) => const Text('mobile')),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('desktop falls back to tablet, then mobile', (t) async {
      await pumpAt(
        t,
        const Size(1200, 800),
        MKResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);

      await pumpAt(
        t,
        const Size(1200, 800),
        MKResponsiveBuilder(mobile: (_) => const Text('mobile')),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('smallMobile falls back to mobile when unset', (t) async {
      await pumpAt(
        t,
        const Size(300, 800),
        MKResponsiveBuilder(mobile: (_) => const Text('mobile')),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('custom breakpoints are respected', (t) async {
      await pumpAt(
        t,
        const Size(500, 800),
        MKResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
          tabletBreakpoint: 480,
        ),
      );
      expect(find.text('tablet'), findsOneWidget);
    });
  });

  group('context.deviceType / context.resValue', () {
    testWidgets('deviceType matches width tier', (t) async {
      late MKDeviceType type;
      await pumpAt(
        t,
        const Size(1200, 800),
        Builder(
          builder: (c) {
            type = c.deviceType;
            return const SizedBox();
          },
        ),
      );
      expect(type, MKDeviceType.desktop);
    });

    testWidgets('resValue picks the value for the current tier', (t) async {
      late double v;
      await pumpAt(
        t,
        const Size(700, 800),
        Builder(
          builder: (c) {
            v = c.resValue(mobile: 16, tablet: 24, desktop: 32);
            return const SizedBox();
          },
        ),
      );
      expect(v, 24);
    });

    testWidgets('resValue falls back to mobile when tier is unset', (t) async {
      late double v;
      await pumpAt(
        t,
        const Size(1200, 800),
        Builder(
          builder: (c) {
            v = c.resValue(mobile: 16, tablet: 24);
            return const SizedBox();
          },
        ),
      );
      expect(v, 24);
    });
  });
}
