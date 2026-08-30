import 'package:cloud_firestore/cloud_firestore.dart';

class SafetyTip {
  final String tipId;
  final String title;
  final String description;
  final String icon;
  final bool isActive;

  const SafetyTip({
    required this.tipId,
    required this.title,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipId': tipId,
      'title': title,
      'description': description,
      'icon': icon,
      'isActive': isActive,
    };
  }

  factory SafetyTip.fromMap(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Safety tip document has no data.',
      );
    }

    return SafetyTip(
      tipId:
          data['tipId']?.toString() ??
              document.id,
      title:
          data['title']?.toString() ??
              '',
      description:
          data['description']?.toString() ??
              '',
      icon:
          data['icon']?.toString() ??
              'info',
      isActive:
          data['isActive'] == true,
    );
  }
}