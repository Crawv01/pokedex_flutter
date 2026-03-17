import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/pokemon.dart';
import '../repositories/pokemon_repository.dart';
import '../services/api_service.dart';

// Retro Pokedex Colors
class _Colors {
  static const Color redDark = Color(0xFFB71C1C);
  static const Color redPrimary = Color(0xFFD32F2F);
  static const Color screenGreen = Color(0xFF9EBC9E);
  static const Color screenDark = Color(0xFF2D4F2D);
  static const Color blueLight = Color(0xFF03A9F4);
  static const Color blackFrame = Color(0xFF1A1A1A);
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  String? type;
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalCount = 0;
  String _sortBy = 'number';
  bool _isLoading = false;
  List<Pokemon> _pokemonList = [];
  String? _errorMessage;

  final int _pageSize = 20;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && type == null) {
      type = args['type'] as String?;
      if (type != null) {
        _loadPage(0);
      }
    }
  }

  Future<void> _loadPage(int page) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<PokemonRepository>();
      final result = await repository.getPokemonByType(
        type!,
        page: page,
        pageSize: _pageSize,
        sortBy: _sortBy,
      );

      setState(() {
        _pokemonList = result.pokemon;
        _currentPage = result.currentPage;
        _totalPages = result.totalPages;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load: $e';
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _loadPage(_currentPage + 1);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _loadPage(_currentPage - 1);
    }
  }

  void _changeSortBy(String sort) {
    if (_sortBy != sort) {
      setState(() => _sortBy = sort);
      _loadPage(0); // Reset to first page when sorting changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.redPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(child: _buildContent()),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.blackFrame, width: 3),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _Colors.blackFrame, width: 2),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor(type ?? ''),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              (type ?? 'ALL').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$_totalCount FOUND',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Colors.blackFrame, width: 2),
      ),
      child: Row(
        children: [
          const Text(
            'SORT:',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          _buildSortButton('NUMBER', 'number'),
          const SizedBox(width: 6),
          _buildSortButton('NAME', 'name'),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => _changeSortBy(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _Colors.blueLight : Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _Colors.blackFrame, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.blackFrame, width: 3),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _Colors.screenGreen,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _Colors.blackFrame, width: 3),
        ),
        child: _buildListContent(),
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _Colors.screenDark),
            SizedBox(height: 16),
            Text(
              'LOADING...',
              style: TextStyle(
                fontFamily: 'monospace',
                color: _Colors.screenDark,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: _Colors.screenDark),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: _Colors.screenDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildRetroButton('RETRY', () => _loadPage(_currentPage)),
          ],
        ),
      );
    }

    if (_pokemonList.isEmpty) {
      return const Center(
        child: Text(
          'NO POKEMON FOUND',
          style: TextStyle(
            fontFamily: 'monospace',
            color: _Colors.screenDark,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = _pokemonList[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/pokemon-detail',
              arguments: {'pokemonId': pokemon.id},
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7A9A7A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _Colors.screenDark, width: 2),
            ),
            child: Row(
              children: [
                // Pokemon image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _Colors.screenGreen,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _Colors.screenDark),
                  ),
                  child: Image.network(
                    pokemon.imageUrl,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.catching_pokemon,
                      size: 40,
                      color: _Colors.screenDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Pokemon info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pokemon.displayName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _Colors.screenDark,
                        ),
                      ),
                      Text(
                        pokemon.formattedId,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: _Colors.screenDark.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: pokemon.types.map((t) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(t),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: _Colors.blackFrame),
                            ),
                            child: Text(
                              t.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Icon(
                  Icons.chevron_right,
                  color: _Colors.screenDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.blackFrame, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          GestureDetector(
            onTap: _currentPage > 0 ? _prevPage : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _currentPage > 0 ? _Colors.blueLight : Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _Colors.blackFrame, width: 2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: _currentPage > 0 ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PREV',
                    style: TextStyle(
                      color: _currentPage > 0 ? Colors.white : Colors.grey,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _Colors.screenGreen,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _Colors.blackFrame, width: 2),
            ),
            child: Text(
              'PAGE ${_currentPage + 1} / $_totalPages',
              style: const TextStyle(
                color: _Colors.screenDark,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          
          // Next button
          GestureDetector(
            onTap: _currentPage < _totalPages - 1 ? _nextPage : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _currentPage < _totalPages - 1 ? _Colors.blueLight : Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _Colors.blackFrame, width: 2),
              ),
              child: Row(
                children: [
                  Text(
                    'NEXT',
                    style: TextStyle(
                      color: _currentPage < _totalPages - 1 ? Colors.white : Colors.grey,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: _currentPage < _totalPages - 1 ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _Colors.blueLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _Colors.blackFrame, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    const typeColors = {
      'normal': Color(0xFFA8A878),
      'fire': Color(0xFFF08030),
      'water': Color(0xFF6890F0),
      'electric': Color(0xFFF8D030),
      'grass': Color(0xFF78C850),
      'ice': Color(0xFF98D8D8),
      'fighting': Color(0xFFC03028),
      'poison': Color(0xFFA040A0),
      'ground': Color(0xFFE0C068),
      'flying': Color(0xFFA890F0),
      'psychic': Color(0xFFF85888),
      'bug': Color(0xFFA8B820),
      'rock': Color(0xFFB8A038),
      'ghost': Color(0xFF705898),
      'dragon': Color(0xFF7038F8),
      'dark': Color(0xFF705848),
      'steel': Color(0xFFB8B8D0),
      'fairy': Color(0xFFEE99AC),
    };
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }
}
