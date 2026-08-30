import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleepy_driver/styles/app_colours.dart';

class HomeCard extends StatelessWidget{
final VoidCallback onTap;
final String? svgPath;
final String text;
const HomeCard(
{
  super.key,
  required this.onTap,
  this.svgPath,
  required this.text
}
);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: 120,
        decoration: BoxDecoration(
          color: AppColours.fill,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColours.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           SvgPicture.asset(svgPath!,
           colorFilter: ColorFilter.mode(AppColours.primary, BlendMode.srcIn),
           width: 65,
           height: 65,),
            SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColours.primary
              ),
            ),     
          ],
        ),
      ),
    );
  }
}