import 'package:flutter/material.dart';

class CustomToastDashboard {
  static void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color bgColor,
    required Color txtColor,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;
    bool isRemoved = false;

    void removeToast() {
      if (isRemoved) return;

      isRemoved = true;

      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 60,
          left: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                    BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: txtColor,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      message,
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: txtColor,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(
      const Duration(seconds: 3),
      removeToast,
    );
  }
}