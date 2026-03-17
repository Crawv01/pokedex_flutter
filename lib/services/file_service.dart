import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/pokemon.dart';

/// File Service for local storage operations
/// Handles reading/writing Pokemon data to local files
class FileService {
  
  /// Get the app's documents directory
  Future<Directory> get _documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }
  
  /// Get a file reference in the documents directory
  Future<File> _getFile(String filename) async {
    final dir = await _documentsDirectory;
    return File('${dir.path}/$filename');
  }
  
  // ============ FAVORITES FILE OPERATIONS ============
  
  /// Save favorites list to JSON file
  Future<void> saveFavoritesToFile(List<int> favoriteIds) async {
    try {
      final file = await _getFile('favorites.json');
      final data = json.encode({'favoriteIds': favoriteIds});
      await file.writeAsString(data);
    } catch (e) {
      throw FileServiceException('Failed to save favorites: $e');
    }
  }
  
  /// Load favorites list from JSON file
  Future<List<int>> loadFavoritesFromFile() async {
    try {
      final file = await _getFile('favorites.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        return List<int>.from(data['favoriteIds'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // ============ POKEMON CACHE FILE OPERATIONS ============
  
  /// Save Pokemon data to cache file
  Future<void> cachePokemon(Pokemon pokemon) async {
    try {
      final file = await _getFile('pokemon_${pokemon.id}.json');
      final data = json.encode(pokemon.toJson());
      await file.writeAsString(data);
    } catch (e) {
      throw FileServiceException('Failed to cache Pokemon: $e');
    }
  }
  
  /// Load Pokemon from cache file
  Future<Pokemon?> loadCachedPokemon(int id) async {
    try {
      final file = await _getFile('pokemon_$id.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        return Pokemon.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Cache multiple Pokemon
  Future<void> cachePokemonList(List<Pokemon> pokemonList) async {
    for (final pokemon in pokemonList) {
      await cachePokemon(pokemon);
    }
    
    // Also save the list index
    final file = await _getFile('pokemon_list_index.json');
    final ids = pokemonList.map((p) => p.id).toList();
    await file.writeAsString(json.encode({'ids': ids}));
  }
  
  /// Load cached Pokemon list
  Future<List<Pokemon>> loadCachedPokemonList() async {
    try {
      final indexFile = await _getFile('pokemon_list_index.json');
      if (!await indexFile.exists()) return [];
      
      final content = await indexFile.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      final ids = List<int>.from(data['ids'] ?? []);
      
      final List<Pokemon> pokemonList = [];
      for (final id in ids) {
        final pokemon = await loadCachedPokemon(id);
        if (pokemon != null) {
          pokemonList.add(pokemon);
        }
      }
      return pokemonList;
    } catch (e) {
      return [];
    }
  }
  
  // ============ EXPORT/IMPORT OPERATIONS ============
  
  /// Export favorites to a shareable JSON file
  Future<String> exportFavorites(List<Pokemon> favoritePokemon) async {
    try {
      final file = await _getFile('my_favorites_export.json');
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'count': favoritePokemon.length,
        'pokemon': favoritePokemon.map((p) => {
          'id': p.id,
          'name': p.name,
          'types': p.types,
        }).toList(),
      };
      await file.writeAsString(json.encode(exportData));
      return file.path;
    } catch (e) {
      throw FileServiceException('Failed to export favorites: $e');
    }
  }
  
  /// Import favorites from JSON file
  Future<List<int>> importFavorites(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileServiceException('Import file not found');
      }
      
      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      final pokemonList = data['pokemon'] as List;
      
      return pokemonList.map((p) => p['id'] as int).toList();
    } catch (e) {
      if (e is FileServiceException) rethrow;
      throw FileServiceException('Failed to import favorites: $e');
    }
  }
  
  // ============ SETTINGS FILE OPERATIONS ============
  
  /// Save app settings to file
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final file = await _getFile('settings.json');
      await file.writeAsString(json.encode(settings));
    } catch (e) {
      throw FileServiceException('Failed to save settings: $e');
    }
  }
  
  /// Load app settings from file
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _getFile('settings.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  // ============ UTILITY OPERATIONS ============
  
  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final dir = await _documentsDirectory;
      final files = dir.listSync();
      for (final file in files) {
        if (file is File && file.path.contains('pokemon_')) {
          await file.delete();
        }
      }
    } catch (e) {
      throw FileServiceException('Failed to clear cache: $e');
    }
  }
  
  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final dir = await _documentsDirectory;
      int totalSize = 0;
      final files = dir.listSync();
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists(String filename) async {
    final file = await _getFile(filename);
    return file.exists();
  }
}

/// Custom exception for file service errors
class FileServiceException implements Exception {
  final String message;
  
  FileServiceException(this.message);
  
  @override
  String toString() => 'FileServiceException: $message';
}
