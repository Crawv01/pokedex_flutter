/// Type effectiveness data for Pokemon types
/// Contains strengths (super effective against) and weaknesses (takes super effective damage from)
class TypeEffectiveness {
  /// Types this type is strong against (deals 2x damage)
  static Map<String, List<String>> strongAgainst = {
    'normal': [],
    'fire': ['grass', 'bug', 'ice', 'steel'],
    'water': ['fire', 'ground', 'rock'],
    'electric': ['water', 'flying'],
    'grass': ['water', 'ground', 'rock'],
    'ice': ['grass', 'ground', 'flying', 'dragon'],
    'fighting': ['normal', 'ice', 'rock', 'dark', 'steel'],
    'poison': ['grass', 'fairy'],
    'ground': ['fire', 'electric', 'poison', 'rock', 'steel'],
    'flying': ['grass', 'fighting', 'bug'],
    'psychic': ['fighting', 'poison'],
    'bug': ['grass', 'psychic', 'dark'],
    'rock': ['fire', 'ice', 'flying', 'bug'],
    'ghost': ['psychic', 'ghost'],
    'dragon': ['dragon'],
    'dark': ['psychic', 'ghost'],
    'steel': ['ice', 'rock', 'fairy'],
    'fairy': ['fighting', 'dragon', 'dark'],
  };

  /// Types this type is weak against (takes 2x damage)
  static Map<String, List<String>> weakAgainst = {
    'normal': ['fighting'],
    'fire': ['water', 'ground', 'rock'],
    'water': ['electric', 'grass'],
    'electric': ['ground'],
    'grass': ['fire', 'ice', 'poison', 'flying', 'bug'],
    'ice': ['fire', 'fighting', 'rock', 'steel'],
    'fighting': ['flying', 'psychic', 'fairy'],
    'poison': ['ground', 'psychic'],
    'ground': ['water', 'grass', 'ice'],
    'flying': ['electric', 'ice', 'rock'],
    'psychic': ['bug', 'ghost', 'dark'],
    'bug': ['fire', 'flying', 'rock'],
    'rock': ['water', 'grass', 'fighting', 'ground', 'steel'],
    'ghost': ['ghost', 'dark'],
    'dragon': ['ice', 'dragon', 'fairy'],
    'dark': ['fighting', 'bug', 'fairy'],
    'steel': ['fire', 'fighting', 'ground'],
    'fairy': ['poison', 'steel'],
  };

  /// Types this type is resistant to (takes 0.5x damage)
  static Map<String, List<String>> resistantTo = {
    'normal': [],
    'fire': ['fire', 'grass', 'ice', 'bug', 'steel', 'fairy'],
    'water': ['fire', 'water', 'ice', 'steel'],
    'electric': ['electric', 'flying', 'steel'],
    'grass': ['water', 'electric', 'grass', 'ground'],
    'ice': ['ice'],
    'fighting': ['bug', 'rock', 'dark'],
    'poison': ['grass', 'fighting', 'poison', 'bug', 'fairy'],
    'ground': ['poison', 'rock'],
    'flying': ['grass', 'fighting', 'bug'],
    'psychic': ['fighting', 'psychic'],
    'bug': ['grass', 'fighting', 'ground'],
    'rock': ['normal', 'fire', 'poison', 'flying'],
    'ghost': ['poison', 'bug'],
    'dragon': ['fire', 'water', 'electric', 'grass'],
    'dark': ['ghost', 'dark'],
    'steel': ['normal', 'grass', 'ice', 'flying', 'psychic', 'bug', 'rock', 'dragon', 'steel', 'fairy'],
    'fairy': ['fighting', 'bug', 'dark'],
  };

  /// Types this type is immune to (takes 0x damage)
  static Map<String, List<String>> immuneTo = {
    'normal': ['ghost'],
    'fire': [],
    'water': [],
    'electric': [],
    'grass': [],
    'ice': [],
    'fighting': [],
    'poison': [],
    'ground': ['electric'],
    'flying': ['ground'],
    'psychic': [],
    'bug': [],
    'rock': [],
    'ghost': ['normal', 'fighting'],
    'dragon': [],
    'dark': ['psychic'],
    'steel': ['poison'],
    'fairy': ['dragon'],
  };

  /// Get combined weaknesses for a Pokemon with one or more types
  static List<String> getWeaknesses(List<String> types) {
    Set<String> weaknesses = {};
    Set<String> resistances = {};
    Set<String> immunities = {};

    for (String type in types) {
      final typeLower = type.toLowerCase();
      weaknesses.addAll(weakAgainst[typeLower] ?? []);
      resistances.addAll(resistantTo[typeLower] ?? []);
      immunities.addAll(immuneTo[typeLower] ?? []);
    }

    // Remove resistances and immunities from weaknesses
    weaknesses.removeAll(resistances);
    weaknesses.removeAll(immunities);

    return weaknesses.toList()..sort();
  }

  /// Get combined strengths for a Pokemon with one or more types
  static List<String> getStrengths(List<String> types) {
    Set<String> strengths = {};

    for (String type in types) {
      final typeLower = type.toLowerCase();
      strengths.addAll(strongAgainst[typeLower] ?? []);
    }

    return strengths.toList()..sort();
  }

  /// Get combined resistances for a Pokemon with one or more types
  static List<String> getResistances(List<String> types) {
    Set<String> resistances = {};
    Set<String> weaknesses = {};

    for (String type in types) {
      final typeLower = type.toLowerCase();
      resistances.addAll(resistantTo[typeLower] ?? []);
      resistances.addAll(immuneTo[typeLower] ?? []);
      weaknesses.addAll(weakAgainst[typeLower] ?? []);
    }

    // Remove weaknesses from resistances
    resistances.removeAll(weaknesses);

    return resistances.toList()..sort();
  }

  /// Get immunities for a Pokemon with one or more types
  static List<String> getImmunities(List<String> types) {
    Set<String> immunities = {};

    for (String type in types) {
      final typeLower = type.toLowerCase();
      immunities.addAll(immuneTo[typeLower] ?? []);
    }

    return immunities.toList()..sort();
  }
}
