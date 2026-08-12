import 'package:flutter/material.dart';
import '../../core/themes/app_themes.dart';

class Avatar {
  final String id;
  final String name;
  final int cost;
  final int requiredStars;
  final int requiredLevel;
  final IconData icon;
  final AppRarity rarity;
  final String effect;

  const Avatar({
    required this.id,
    required this.name,
    required this.cost,
    required this.requiredStars,
    required this.requiredLevel,
    required this.icon,
    required this.rarity,
    required this.effect,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: json['cost'] as int,
      requiredStars: json['requiredStars'] as int,
      requiredLevel: json['requiredLevel'] as int,
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      rarity: AppRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AppRarity.common,
      ),
      effect: json['effect'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'requiredStars': requiredStars,
      'requiredLevel': requiredLevel,
      'iconCodePoint': icon.codePoint,
      'rarity': rarity.name,
      'effect': effect,
    };
  }
}
