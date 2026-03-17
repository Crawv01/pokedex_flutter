import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/pokemon/pokemon_bloc.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

// Retro Pokedex Colors
class PokedexColors {
  static const Color redDark = Color(0xFFB71C1C);
  static const Color redPrimary = Color(0xFFD32F2F);
  static const Color screenGreen = Color(0xFF9EBC9E);
  static const Color screenDark = Color(0xFF2D4F2D);
  static const Color blueLight = Color(0xFF03A9F4);
  static const Color blackFrame = Color(0xFF1A1A1A);
  static const Color cream = Color(0xFFF5F5DC);
}

/// HomeScreen - Main screen with retro Pokedex theme
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pokemonTypes = [
    {'name': 'fire', 'color': Colors.orange},
    {'name': 'water', 'color': Colors.blue},
    {'name': 'grass', 'color': Colors.green},
    {'name': 'electric', 'color': Colors.amber},
    {'name': 'psychic', 'color': Colors.purple},
    {'name': 'ice', 'color': Colors.cyan},
    {'name': 'dragon', 'color': Colors.indigo},
    {'name': 'dark', 'color': Colors.brown},
    {'name': 'fairy', 'color': Colors.pink},
    {'name': 'fighting', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    context.read<PokemonBloc>().add(const PokemonListRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      context.read<PokemonBloc>().add(PokemonSearchRequested(query: query));
    } else {
      context.read<PokemonBloc>().add(const PokemonListRequested());
    }
  }

  void _onTypeSelected(String type) {
    Navigator.pushNamed(context, '/pokemon-list', arguments: {'type': type});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PokedexColors.redPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeContent(),
                  const FavoritesScreen(embedded: true),
                  const SettingsScreen(embedded: true),
                ],
              ),
            ),
            _buildBottomNav(),
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
        color: PokedexColors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PokedexColors.blackFrame, width: 3),
      ),
      child: Row(
        children: [
          // Blue light indicator
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PokedexColors.blueLight,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: PokedexColors.blueLight.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Small indicator lights
          _buildSmallLight(Colors.red),
          _buildSmallLight(Colors.yellow),
          _buildSmallLight(Colors.green),
          const Spacer(),
          const Text(
            'POKÉDEX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          // Logout button
          GestureDetector(
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: PokedexColors.blackFrame, width: 2),
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLight(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: PokedexColors.blackFrame, width: 1),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: PokedexColors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PokedexColors.blackFrame, width: 3),
      ),
      child: Column(
        children: [
          // Search bar area
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PokedexColors.screenGreen,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PokedexColors.blackFrame, width: 2),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: PokedexColors.screenDark,
              ),
              decoration: InputDecoration(
                hintText: 'SEARCH POKEMON...',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  color: PokedexColors.screenDark.withOpacity(0.5),
                ),
                prefixIcon: const Icon(Icons.search, color: PokedexColors.screenDark),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: _onSearch,
            ),
          ),

          // Type filter chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pokemonTypes.length,
              itemBuilder: (context, index) {
                final type = _pokemonTypes[index];
                return GestureDetector(
                  onTap: () => _onTypeSelected(type['name']),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: type['color'] as Color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: PokedexColors.blackFrame, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        type['name'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Pokemon Grid
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PokedexColors.screenGreen,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PokedexColors.blackFrame, width: 3),
              ),
              child: BlocBuilder<PokemonBloc, PokemonState>(
                builder: (context, state) {
                  if (state.status == PokemonStatus.loading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: PokedexColors.screenDark),
                          SizedBox(height: 16),
                          Text(
                            'LOADING...',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: PokedexColors.screenDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.status == PokemonStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: PokedexColors.screenDark),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'ERROR',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: PokedexColors.screenDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRetroButton('RETRY', () {
                            context.read<PokemonBloc>().add(const PokemonListRequested());
                          }),
                        ],
                      ),
                    );
                  }

                  if (state.pokemonList.isEmpty) {
                    return const Center(
                      child: Text(
                        'NO POKEMON FOUND',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: PokedexColors.screenDark,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: state.pokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = state.pokemonList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/pokemon-detail',
                            arguments: {'pokemonId': pokemon.id},
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A9A7A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PokedexColors.screenDark, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                pokemon.imageUrl,
                                height: 70,
                                width: 70,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.catching_pokemon,
                                  size: 70,
                                  color: PokedexColors.screenDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pokemon.displayName.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: PokedexColors.screenDark,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                pokemon.formattedId,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: PokedexColors.screenDark.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
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
          color: PokedexColors.blueLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PokedexColors.blackFrame, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
            ),
          ],
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

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: PokedexColors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PokedexColors.blackFrame, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(Icons.home, 'HOME', 0),
          _buildNavButton(Icons.favorite, 'FAVORITES', 1),
          _buildNavButton(Icons.settings, 'SETTINGS', 2),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? PokedexColors.blueLight : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PokedexColors.blackFrame, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
