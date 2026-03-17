import 'package:equatable/equatable.dart';

/// Pokemon model representing a Pokemon entity
class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int specialAttack;
  final int specialDefense;
  final int height;
  final int weight;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    this.hp = 0,
    this.attack = 0,
    this.defense = 0,
    this.speed = 0,
    this.specialAttack = 0,
    this.specialDefense = 0,
    this.height = 0,
    this.weight = 0,
  });

  /// Create Pokemon from PokeAPI JSON response
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Extract types
    final typesList = (json['types'] as List?)?.map((t) {
      if (t is Map) {
        return t['type']['name'] as String;
      }
      return t.toString();
    }).toList() ?? [];

    // Extract stats
    int hp = 0, attack = 0, defense = 0, speed = 0, spAtk = 0, spDef = 0;
    final stats = json['stats'] as List?;
    if (stats != null) {
      for (final stat in stats) {
        final statName = stat['stat']['name'] as String;
        final baseStat = stat['base_stat'] as int;
        switch (statName) {
          case 'hp':
            hp = baseStat;
            break;
          case 'attack':
            attack = baseStat;
            break;
          case 'defense':
            defense = baseStat;
            break;
          case 'speed':
            speed = baseStat;
            break;
          case 'special-attack':
            spAtk = baseStat;
            break;
          case 'special-defense':
            spDef = baseStat;
            break;
        }
      }
    }

    // Get sprite URL
    String imageUrl = '';
    final sprites = json['sprites'];
    if (sprites != null) {
      imageUrl = sprites['other']?['official-artwork']?['front_default'] ??
          sprites['front_default'] ??
          '';
    }

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: imageUrl,
      types: typesList,
      hp: hp,
      attack: attack,
      defense: defense,
      speed: speed,
      specialAttack: spAtk,
      specialDefense: spDef,
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
    );
  }

  /// Convert Pokemon to JSON for file storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sprites': {
        'other': {
          'official-artwork': {
            'front_default': imageUrl,
          }
        },
        'front_default': imageUrl,
      },
      'types': types.map((t) => {'type': {'name': t}}).toList(),
      'stats': [
        {'stat': {'name': 'hp'}, 'base_stat': hp},
        {'stat': {'name': 'attack'}, 'base_stat': attack},
        {'stat': {'name': 'defense'}, 'base_stat': defense},
        {'stat': {'name': 'speed'}, 'base_stat': speed},
        {'stat': {'name': 'special-attack'}, 'base_stat': specialAttack},
        {'stat': {'name': 'special-defense'}, 'base_stat': specialDefense},
      ],
      'height': height,
      'weight': weight,
    };
  }

  /// Formatted ID with leading zeros (e.g., #001)
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  /// Display name with first letter capitalized
  String get displayName => name[0].toUpperCase() + name.substring(1);

  /// Height in meters
  String get heightInMeters => '${(height / 10).toStringAsFixed(1)} m';

  /// Weight in kilograms
  String get weightInKg => '${(weight / 10).toStringAsFixed(1)} kg';

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        types,
        hp,
        attack,
        defense,
        speed,
        specialAttack,
        specialDefense,
      ];
}
