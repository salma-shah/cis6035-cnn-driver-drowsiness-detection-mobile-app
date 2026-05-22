import 'package:flutter/material.dart';
import 'package:sleepy_driver/styles/app_colours.dart';

class CustomToast {
  static void show(
{
  required BuildContext context, 
  required String message,
  IconData icon = Icons.info_outline,
  Color bgColor = AppColours.primary,
  Color txtColor = AppColours.lightButtonText
}
) 

{
   final overlay =
        Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 60,
          left: 10,
          right: 10,

          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 3000,
              ),

              padding:
                const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),

              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),

                boxShadow: [

                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset:
                        const Offset(0, 4),
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
                      textAlign: TextAlign.center,
                      message,
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

    overlay.insert(
      overlayEntry,
    );

    Future.delayed(
      const Duration(
        seconds: 3,
      ),
      () {
        overlayEntry.remove();
      },
    );
}
}