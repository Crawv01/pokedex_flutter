import '../models/pokemon.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';

/// Pokemon Repository
/// Coordinates between REST API and local file storage
class PokemonRepository {
  final ApiService _apiService;
  final FileService _fileService;
  
  PokemonRepository({
    ApiService? apiService,
    FileService? fileService,
  })  : _apiService = apiService ?? ApiService(),
        _fileService = fileService ?? FileService();
  
  /// Get Pokemon list - tries cache first, then API
  Future<List<Pokemon>> getPokemonList({String? type}) async {
    try {
      if (type != null) {
        // Use paginated method, return first page
        final result = await _apiService.fetchPokemonByType(type);
        return result.pokemon;
      }
      
      // Try loading from cache first
      final cachedList = await _fileService.loadCachedPokemonList();
      if (cachedList.isNotEmpty) {
        // Refresh in background
        _refreshPokemonList();
        return cachedList;
      }
      
      // Fetch from API and cache
      final pokemonList = await _apiService.fetchPokemonList();
      await _fileService.cachePokemonList(pokemonList);
      return pokemonList;
    } catch (e) {
      // If API fails, try cache
      final cachedList = await _fileService.loadCachedPokemonList();
      if (cachedList.isNotEmpty) {
        return cachedList;
      }
      rethrow;
    }
  }
  
  /// Get Pokemon by type with pagination
  Future<TypePageResult> getPokemonByType(
    String type, {
    int page = 0,
    int pageSize = 20,
    String sortBy = 'number',
  }) async {
    return await _apiService.fetchPokemonByType(
      type,
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
    );
  }
  
  /// Get total count for a type
  Future<int> getTypeTotal(String type) async {
    return await _apiService.getTypeTotal(type);
  }
  
  /// Background refresh of Pokemon list
  Future<void> _refreshPokemonList() async {
    try {
      final pokemonList = await _apiService.fetchPokemonList();
      await _fileService.cachePokemonList(pokemonList);
    } catch (e) {
      // Silently fail background refresh
      print('Background refresh failed: $e');
    }
  }
  
  /// Get Pokemon detail by ID
  Future<Pokemon> getPokemonDetail(int id) async {
    try {
      // Try cache first
      final cached = await _fileService.loadCachedPokemon(id);
      if (cached != null) {
        return cached;
      }
      
      // Fetch from API and cache
      final pokemon = await _apiService.fetchPokemonById(id);
      await _fileService.cachePokemon(pokemon);
      return pokemon;
    } catch (e) {
      // Try cache on API failure
      final cached = await _fileService.loadCachedPokemon(id);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }
  
  /// Search Pokemon by name or ID
  Future<List<Pokemon>> searchPokemon(String query) async {
    return await _apiService.searchPokemon(query);
  }
  
  /// Get multiple Pokemon by IDs
  Future<List<Pokemon>> getPokemonByIds(List<int> ids) async {
    final List<Pokemon> pokemonList = [];
    for (final id in ids) {
      try {
        final pokemon = await getPokemonDetail(id);
        pokemonList.add(pokemon);
      } catch (e) {
        print('Failed to load Pokemon $id: $e');
      }
    }
    return pokemonList;
  }
  
  // ============ FAVORITES (FILE-BASED) ============
  
  /// Get favorite Pokemon IDs
  Future<List<int>> getFavorites() async {
    return await _fileService.loadFavoritesFromFile();
  }
  
  /// Save favorite Pokemon IDs
  Future<void> saveFavorites(List<int> favoriteIds) async {
    await _fileService.saveFavoritesToFile(favoriteIds);
  }
  
  /// Export favorites to file
  Future<String> exportFavorites(List<Pokemon> favorites) async {
    return await _fileService.exportFavorites(favorites);
  }
  
  /// Import favorites from file
  Future<List<int>> importFavorites(String filePath) async {
    return await _fileService.importFavorites(filePath);
  }
  
  // ============ SETTINGS (FILE-BASED) ============
  
  /// Save settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _fileService.saveSettings(settings);
  }
  
  /// Load settings
  Future<Map<String, dynamic>> loadSettings() async {
    return await _fileService.loadSettings();
  }
  
  // ============ CACHE MANAGEMENT ============
  
  /// Clear all cached data
  Future<void> clearCache() async {
    await _fileService.clearCache();
  }
  
  /// Get cache size
  Future<int> getCacheSize() async {
    return await _fileService.getCacheSize();
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
