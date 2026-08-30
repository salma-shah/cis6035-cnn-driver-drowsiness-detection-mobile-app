import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/nav_bar/destination.dart';

class DefaultLayout extends StatelessWidget{
  final StatefulNavigationShell navigationShell;

  const DefaultLayout({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('DefaultLayout'));

  @override
  Widget build(BuildContext context) {
    log('Current Index: ${navigationShell.currentIndex}');
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        destinations: destinations.map(
          (destination) => NavigationDestination(
            icon: destination.icon,
            label: destination.label,
           // selectedIcon: SvgPicture(destination.icon as BytesLoader, colorFilter: ColorFilter.mode(AppColours.secondary, BlendMode.color),)
          ),
        ).toList(),
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.selected))
          {
            return TextStyle(fontSize: 10, 
            fontWeight: FontWeight.w400, 
            color: Theme.of(context).colorScheme.primary,
            overflow: TextOverflow.visible);
          }
          return TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.primary, overflow: TextOverflow.visible);

        }),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
  log('Selected: $index');
  navigationShell.goBranch(index);
},
        indicatorColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.tertiary,      
      ),);
  }
   

}