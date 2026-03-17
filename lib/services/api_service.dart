import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

/// REST API Service for PokeAPI
/// Handles all HTTP requests with proper error handling
class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  
  final http.Client _client;
  
  // Cache type data to avoid re-fetching
  final Map<String, List<Map<String, dynamic>>> _typeCache = {};
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  /// GET request with error handling
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw ApiException('Resource not found', response.statusCode);
      } else if (response.statusCode >= 500) {
        throw ApiException('Server error', response.statusCode);
      } else {
        throw ApiException('Request failed', response.statusCode);
      }
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e', 0);
    }
  }
  
  /// Fetch list of Pokemon with pagination
  Future<List<Pokemon>> fetchPokemonList({int limit = 20, int offset = 0}) async {
    final data = await get('/pokemon?limit=$limit&offset=$offset');
    final results = data['results'] as List;
    
    // Fetch details for each Pokemon
    final List<Pokemon> pokemonList = [];
    for (final item in results) {
      try {
        final pokemon = await fetchPokemonByUrl(item['url']);
        pokemonList.add(pokemon);
      } catch (e) {
        // Skip Pokemon that fail to load
        print('Failed to load ${item['name']}: $e');
      }
    }
    
    return pokemonList;
  }
  
  /// Fetch Pokemon by URL (from list results)
  Future<Pokemon> fetchPokemonByUrl(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Pokemon.fromJson(json.decode(response.body));
    }
    throw ApiException('Failed to fetch Pokemon', response.statusCode);
  }
  
  /// Fetch Pokemon by ID
  Future<Pokemon> fetchPokemonById(int id) async {
    final data = await get('/pokemon/$id');
    return Pokemon.fromJson(data);
  }
  
  /// Fetch Pokemon by name
  Future<Pokemon> fetchPokemonByName(String name) async {
    final data = await get('/pokemon/${name.toLowerCase()}');
    return Pokemon.fromJson(data);
  }
  
  /// Get total count of Pokemon for a type
  Future<int> getTypeTotal(String type) async {
    if (_typeCache.containsKey(type)) {
      return _typeCache[type]!.length;
    }
    
    final data = await get('/type/${type.toLowerCase()}');
    final pokemonEntries = data['pokemon'] as List;
    _typeCache[type] = pokemonEntries.map((e) => e as Map<String, dynamic>).toList();
    return pokemonEntries.length;
  }
  
  /// Fetch Pokemon by type with pagination
  Future<TypePageResult> fetchPokemonByType(
    String type, {
    int page = 0,
    int pageSize = 20,
    String sortBy = 'number', // 'number', 'name'
  }) async {
    // Get or fetch type data
    if (!_typeCache.containsKey(type)) {
      final data = await get('/type/${type.toLowerCase()}');
      final pokemonEntries = data['pokemon'] as List;
      _typeCache[type] = pokemonEntries.map((e) => e as Map<String, dynamic>).toList();
    }
    
    final allEntries = _typeCache[type]!;
    final totalCount = allEntries.length;
    final totalPages = (totalCount / pageSize).ceil();
    
    // Calculate pagination
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, totalCount);
    
    if (startIndex >= totalCount) {
      return TypePageResult(
        pokemon: [],
        currentPage: page,
        totalPages: totalPages,
        totalCount: totalCount,
      );
    }
    
    final pageEntries = allEntries.sublist(startIndex, endIndex);
    
    // Fetch Pokemon details
    final List<Pokemon> pokemonList = [];
    for (final entry in pageEntries) {
      try {
        final pokemon = await fetchPokemonByUrl(entry['pokemon']['url']);
        pokemonList.add(pokemon);
      } catch (e) {
        print('Failed to load Pokemon: $e');
      }
    }
    
    // Sort the results
    if (sortBy == 'name') {
      pokemonList.sort((a, b) => a.name.compareTo(b.name));
    } else {
      pokemonList.sort((a, b) => a.id.compareTo(b.id));
    }
    
    return TypePageResult(
      pokemon: pokemonList,
      currentPage: page,
      totalPages: totalPages,
      totalCount: totalCount,
    );
  }
  
  /// Search Pokemon (fetches by name or ID)
  Future<List<Pokemon>> searchPokemon(String query) async {
    try {
      // Try as ID first
      final id = int.tryParse(query);
      if (id != null) {
        final pokemon = await fetchPokemonById(id);
        return [pokemon];
      }
      
      // Try as name
      final pokemon = await fetchPokemonByName(query);
      return [pokemon];
    } catch (e) {
      return [];
    }
  }
  
  void dispose() {
    _client.close();
  }
}

/// Result class for paginated type queries
class TypePageResult {
  final List<Pokemon> pokemon;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  
  TypePageResult({
    required this.pokemon,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
