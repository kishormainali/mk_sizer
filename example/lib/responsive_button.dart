import 'package:flutter/material.dart';
import 'package:mk_sizer/mk_sizer.dart';

enum ButtonVariant { primary, secondary, outline }

enum ButtonSize { small, medium, large }

/// A design-system-style button whose height, padding, font size and corner
/// radius all come from mk_sizer, so the whole thing scales together with
/// the rest of the UI and adapts per device tier (via [context.resValue]).
class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;

  // Base dimensions at the design size; .h/.w/.sp/.r below adapt them to the
  // actual screen, and context.resValue nudges padding/font per device tier.
  double _baseHeight() => switch (size) {
    ButtonSize.small => 36.h,
    ButtonSize.medium => 48.h,
    ButtonSize.large => 56.h,
  };

  @override
  Widget build(BuildContext context) {
    final height = _baseHeight();
    final radius = switch (size) {
      ButtonSize.small => 8.r,
      ButtonSize.medium => 10.r,
      ButtonSize.large => 12.r,
    };
    // Horizontal padding and font size grow a step per device tier, on top
    // of the usual .w/.sp screen-size scaling.
    final horizontalPadding = context.resValue(
      smallMobile: switch (size) {
        ButtonSize.small => 12.w,
        ButtonSize.medium => 16.w,
        ButtonSize.large => 20.w,
      },
      mobile: switch (size) {
        ButtonSize.small => 16.w,
        ButtonSize.medium => 20.w,
        ButtonSize.large => 24.w,
      },
      tablet: switch (size) {
        ButtonSize.small => 20.w,
        ButtonSize.medium => 28.w,
        ButtonSize.large => 32.w,
      },
      desktop: switch (size) {
        ButtonSize.small => 24.w,
        ButtonSize.medium => 32.w,
        ButtonSize.large => 40.w,
      },
    );
    final fontSize = context.resValue(
      smallMobile: switch (size) {
        ButtonSize.small => 12.sp,
        ButtonSize.medium => 14.sp,
        ButtonSize.large => 16.sp,
      },
      mobile: switch (size) {
        ButtonSize.small => 13.sp,
        ButtonSize.medium => 15.sp,
        ButtonSize.large => 17.sp,
      },
      tablet: switch (size) {
        ButtonSize.small => 14.sp,
        ButtonSize.medium => 16.sp,
        ButtonSize.large => 18.sp,
      },
      desktop: switch (size) {
        ButtonSize.small => 15.sp,
        ButtonSize.medium => 17.sp,
        ButtonSize.large => 19.sp,
      },
    );

    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, border) = switch (variant) {
      ButtonVariant.primary => (
        colorScheme.primary,
        colorScheme.onPrimary,
        null,
      ),
      ButtonVariant.secondary => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        null,
      ),
      ButtonVariant.outline => (
        Colors.transparent,
        colorScheme.primary,
        colorScheme.primary,
      ),
    };

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: variant == ButtonVariant.outline ? 0 : 1,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: border != null ? BorderSide(color: border) : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Shows every variant/size pair plus the per-tier padding/font size, so the
/// effect of resizing the window or switching simulators is visible at a
/// glance.
class ResponsiveButtonGallery extends StatelessWidget {
  const ResponsiveButtonGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tier: ${context.deviceType.name} — padding/font step up at each breakpoint',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        12.h.verticalSpace,
        for (final size in ButtonSize.values) ...[
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ResponsiveButton(
                label: '${size.name} primary',
                size: size,
                onPressed: () {},
              ),
              ResponsiveButton(
                label: '${size.name} secondary',
                size: size,
                variant: ButtonVariant.secondary,
                onPressed: () {},
              ),
              ResponsiveButton(
                label: '${size.name} outline',
                size: size,
                variant: ButtonVariant.outline,
                onPressed: () {},
              ),
            ],
          ),
          12.h.verticalSpace,
        ],
      ],
    );
  }
}
