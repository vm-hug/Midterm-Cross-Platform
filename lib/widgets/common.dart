import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 36,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
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
    final fallback = ColoredBox(
      color: const Color(0xffe0f1ef),
      child: Center(
        child: Text(
          name.trim().isEmpty
              ? '?'
              : name.trim().characters.first.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff087e79),
          ),
        ),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
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
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}
