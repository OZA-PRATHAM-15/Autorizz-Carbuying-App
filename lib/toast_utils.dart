import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showCustomToast(BuildContext context, String message, bool isError,
    {Duration? duration, String? actionLabel, VoidCallback? onActionPressed}) {
  // Define a default duration based on message length.
  Duration toastDuration = duration ??
      (message.length > 50 ? Duration(seconds: 6) : Duration(seconds: 4));

  Flushbar(
    messageText: Text(
      message,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
    duration: toastDuration,
    backgroundColor: isError ? Colors.redAccent : Colors.greenAccent.shade700,
    flushbarPosition: FlushbarPosition.BOTTOM,
    borderRadius: BorderRadius.circular(12),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: EdgeInsets.all(16),
    animationDuration: Duration(milliseconds: 600),
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: Offset(0, 4),
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
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              actionLabel,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )
        : null,
    onTap: (flushbar) {
      // Handle flushbar tap if needed
    },
    // Additional visual enhancement: position the toast above keyboard if visible
    positionOffset: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0,
  )..show(context);
}
