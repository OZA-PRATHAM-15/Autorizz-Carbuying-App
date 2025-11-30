import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showCustomToast(BuildContext context, String message, bool isError,
    {Duration? duration, String? actionLabel, VoidCallback? onActionPressed}) {
  Duration toastDuration = duration ??
      (message.length > 50
          ? const Duration(seconds: 6)
          : const Duration(seconds: 4));

  Flushbar(
    messageText: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
    duration: toastDuration,
    backgroundColor: isError ? Colors.redAccent : Colors.greenAccent.shade700,
    flushbarPosition: FlushbarPosition.BOTTOM,
    borderRadius: BorderRadius.circular(12),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: const EdgeInsets.all(16),
    animationDuration: const Duration(milliseconds: 600),
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withAlpha((0.3 * 255).toInt()),
        offset: const Offset(0, 4),
        blurRadius: 12,
      ),
    ],
    icon: Icon(
      isError ? Icons.error : Icons.check_circle,
      color: Colors.white,
      size: 30,
    ),
    leftBarIndicatorColor: isError ? Colors.red : Colors.green,
    isDismissible: true,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    mainButton: actionLabel != null
        ? TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: Colors.black.withAlpha((0.2 * 255).toInt()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )
        : null,
    onTap: (flushbar) {},
    positionOffset: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0,
  ).show(context);
}
