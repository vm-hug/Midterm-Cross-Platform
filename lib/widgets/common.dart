import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Huy hiệu icon bo tròn hiện đại với hiệu ứng gradient hoặc nền pastel
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 22,
    this.gradient,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 14,
    this.border,
    this.boxShadow,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradient ??
        (backgroundColor == null
            ? const LinearGradient(
                colors: [Color(0x3366ffff), Color(0x33cc99ff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null);

    final effectiveColor =
        iconColor ??
        (gradient != null ? Colors.white : AppTheme.purplePrimary);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveGradient == null ? (backgroundColor ?? Colors.white) : null,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: AppTheme.purplePastel.withValues(alpha: 0.35),
              width: 1.2,
            ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppTheme.purplePastel.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: effectiveColor),
    );
  }
}

/// Nút bấm Gradient rực rỡ mang phong cách Cyber-Pastel
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.busy = false,
    this.gradient,
    this.height = 52,
    this.width,
  });

  final VoidCallback? onPressed;
  final Widget label;
  final Widget? icon;
  final bool busy;
  final Gradient? gradient;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradient ??
        const LinearGradient(
          colors: [Color(0xff6366f1), Color(0xff8b5cf6), Color(0xffa855f7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

    final isEnabled = onPressed != null && !busy;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? effectiveGradient
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppTheme.purplePrimary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 10),
                ],
                DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  child: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.navy,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.purplePastel.withValues(alpha: 0.3),
              foregroundColor: AppTheme.purpleDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ],
    ),
  );
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.url,
    this.radius = 22,
  });

  final String name;
  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();

    final fallback = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.cyanLight, AppTheme.purplePastel],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.purpleDark,
            fontSize: radius * 0.9,
          ),
        ),
      ),
    );

    return Container(
      width: radius * 2,
      height: radius * 2,
      padding: const EdgeInsets.all(2), // Viền gradient mỏng bao quanh avatar
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.purplePastel.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: url.isEmpty
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.cyanBright,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.purpleDark,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 4),
    ),
  );
}
