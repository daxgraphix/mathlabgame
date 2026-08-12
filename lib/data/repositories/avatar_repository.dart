import 'package:flutter/material.dart';
import '../models/avatar.dart';
import '../../core/themes/app_themes.dart';

class AvatarRepository {
  Future<List<Avatar>> getAvatars() async {
    // In a real app, this might come from a local DB or remote API
    return [
      const Avatar(id: 'circle', name: 'Circle', cost: 0, requiredStars: 0, requiredLevel: 1, icon: Icons.circle, rarity: AppRarity.common, effect: 'None'),
      const Avatar(id: 'square', name: 'Square', cost: 0, requiredStars: 0, requiredLevel: 1, icon: Icons.square, rarity: AppRarity.common, effect: 'None'),
      const Avatar(id: 'star', name: 'Star', cost: 0, requiredStars: 0, requiredLevel: 1, icon: Icons.star, rarity: AppRarity.common, effect: 'None'),
      const Avatar(id: 'diamond', name: 'Diamond', cost: 500, requiredStars: 5, requiredLevel: 2, icon: Icons.diamond, rarity: AppRarity.rare, effect: 'Glitter'),
      const Avatar(id: 'shield', name: 'Shield', cost: 1000, requiredStars: 15, requiredLevel: 5, icon: Icons.shield, rarity: AppRarity.epic, effect: 'Shield Aura'),
      const Avatar(id: 'ninja', name: 'Ninja', cost: 5000, requiredStars: 30, requiredLevel: 10, icon: Icons.sports_martial_arts, rarity: AppRarity.epic, effect: 'Stealth'),
      const Avatar(id: 'crown', name: 'Crown', cost: 2500, requiredStars: 50, requiredLevel: 15, icon: Icons.emoji_events, rarity: AppRarity.legendary, effect: 'Royal Glow'),
      const Avatar(id: 'rocket', name: 'Rocket', cost: 10000, requiredStars: 75, requiredLevel: 20, icon: Icons.rocket_launch, rarity: AppRarity.legendary, effect: 'Rocket Trail'),
      const Avatar(id: 'dragon', name: 'Dragon', cost: 20000, requiredStars: 100, requiredLevel: 25, icon: Icons.local_fire_department, rarity: AppRarity.mythic, effect: 'Fire Breath'),
      const Avatar(id: 'phoenix', name: 'Phoenix', cost: 50000, requiredStars: 150, requiredLevel: 30, icon: Icons.mood, rarity: AppRarity.mythic, effect: 'Rebirth Flame'),
    ];
  }
}
