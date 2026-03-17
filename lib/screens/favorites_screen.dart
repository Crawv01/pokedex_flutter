import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/pokemon/pokemon_bloc.dart';

// Retro Pokedex Colors
class _Colors {
  static const Color redDark = Color(0xFFB71C1C);
  static const Color redPrimary = Color(0xFFD32F2F);
  static const Color screenGreen = Color(0xFF9EBC9E);
  static const Color screenDark = Color(0xFF2D4F2D);
  static const Color blueLight = Color(0xFF03A9F4);
  static const Color blackFrame = Color(0xFF1A1A1A);
}

class FavoritesScreen extends StatefulWidget {
  final bool embedded;
  
  const FavoritesScreen({super.key, this.embedded = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PokemonBloc>().add(const PokemonFavoritesRequested());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }
    
    return Scaffold(
      backgroundColor: _Colors.redPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
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
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 16),
          ),
          const Spacer(),
          const Text(
            'FAVORITES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: widget.embedded 
          ? const EdgeInsets.fromLTRB(8, 0, 8, 8)
          : const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
        child: BlocBuilder<PokemonBloc, PokemonState>(
          builder: (context, state) {
            if (state.status == PokemonStatus.loading) {
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

            final favorites = state.pokemonList.where((p) => 
              state.favoriteIds.contains(p.id)
            ).toList();

            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: _Colors.screenDark.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'NO FAVORITES YET',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: _Colors.screenDark,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart on a Pokemon\nto add it here!',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: _Colors.screenDark.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final pokemon = favorites[index];
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
                      border: Border.all(color: _Colors.screenDark, width: 2),
                    ),
                    child: Stack(
                      children: [
                        Center(
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
                                  color: _Colors.screenDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pokemon.displayName.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: _Colors.screenDark,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                pokemon.formattedId,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: _Colors.screenDark.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Heart icon
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              context.read<PokemonBloc>().add(
                                PokemonFavoriteToggled(pokemonId: pokemon.id),
                              );
                            },
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            ),
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
    );
  }
}
