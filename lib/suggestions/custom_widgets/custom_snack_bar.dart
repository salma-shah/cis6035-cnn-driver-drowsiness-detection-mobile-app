import 'package:flutter/material.dart';
import 'package:sleepy_driver/styles/app_colours.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String message,
    required IconData icon,
    Color backgroundColor =
        AppColours.primary,
    Duration duration =
        const Duration(seconds: 3),
  }) : super(
          behavior:
              SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor:
              Colors.transparent,
          duration: duration,
          margin:
              const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            20,
          ),
          padding: EdgeInsets.zero,
          content: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
                  BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                    alpha: 0.15,
                  ),
                  blurRadius: 12,
                  offset:
                      const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.16,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 21,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    message,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
}