import 'package:flutter/material.dart';
import 'package:mk_sizer/mk_sizer.dart';

import 'responsive_button.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mk_sizer example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: MKSizer(
        designSize: const Size(430, 932),
        respectAspectRatio: true,
        // Keep every device within +/-15% of the design size, so the UI
        // doesn't look noticeably bigger/smaller between e.g. iPhone SE and
        // iPhone 17 Pro Max, while still adapting a little to each screen.
        minScaleFactor: 0.85,
        maxScaleFactor: 1.15,
        // No floor: text should still shrink on small screens, just not
        // balloon past the design size on big ones.
        maxTextScaleFactor: 1.05,
        // Tall Android phones: ignore system bars and keep .h in step with .w.
        heightMode: MKHeightMode.safeArea,
        // Android's font-size setting goes much higher than iOS's; cap it so
        // text looks the same on both.
        minSystemTextScale: 0.9,
        maxSystemTextScale: 1.3,
        builder: (context) => const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final deviceType = context.deviceType;

    return Scaffold(
      appBar: AppBar(
        title: Text('mk_sizer demo', style: TextStyle(fontSize: 18.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Card(
              title: 'Screen',
              child: Text(
                '${mq.width.toStringAsFixed(0)} x ${mq.height.toStringAsFixed(0)} '
                '(logical px)\nDevice tier: ${deviceType.name}',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            20.h.verticalSpace,
            _Card(
              title: '.w / .h / .r / .sp (design 430x932)',
              child: Column(
                children: [
                  Container(
                    width: 200.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.indigo),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '200.w x 80.h, radius 12.r',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  10.h.verticalSpace,
                  Text(
                    'Text at 16.sp',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            20.h.verticalSpace,
            _Card(
              title: 'context.resValue',
              child: Builder(
                builder: (context) {
                  final padding = context.resValue(
                    smallMobile: 8.0,
                    mobile: 16.0,
                    tablet: 24.0,
                    desktop: 32.0,
                  );
                  final columns = context.resValue(
                    smallMobile: 1,
                    mobile: 2,
                    tablet: 3,
                    desktop: 4,
                  );
                  return Text(
                    'padding = $padding, columns = $columns',
                    style: TextStyle(fontSize: 14.sp),
                  );
                },
              ),
            ),
            20.h.verticalSpace,
            _Card(
              title: 'MKResponsiveBuilder',
              child: MKResponsiveBuilder(
                smallMobile: (_) => _Tag('smallMobile layout', Colors.red),
                mobile: (_) => _Tag('mobile layout', Colors.orange),
                tablet: (_) => _Tag('tablet layout', Colors.green),
                desktop: (_) => _Tag('desktop layout', Colors.blue),
              ),
            ),
            20.h.verticalSpace,
            _Card(
              title: 'Responsive button design system',
              child: const ResponsiveButtonGallery(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          8.h.verticalSpace,
          child,
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 14.sp, color: color),
      ),
    );
  }
}
