import 'package:flutter_svg/svg.dart';

class Destination {
  final SvgPicture icon;
  final String label;

  const Destination({
    required this.icon,
    required this.label,
  });
}

// array of destinations
final destinations = [
  Destination(icon: 
    SvgPicture.asset(
        'assets/images/img_home.svg',
        width: 36, height: 36, semanticsLabel: 'Home'), label: 'Home'),
  Destination(
    icon: SvgPicture.asset(
      'assets/images/img_dashboard.svg',
      width: 36, height: 36, semanticsLabel: 'Safety Dashboard',
    ), label: 'Safety Dashboard'),
    Destination(
    icon: SvgPicture.asset(
      'assets/images/img_profile.svg',
      width: 36, height: 36, semanticsLabel: 'Profile',
    ), label: 'Profile'),    
  ];

