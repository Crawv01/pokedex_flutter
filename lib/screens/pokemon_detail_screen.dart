import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/pokemon/pokemon_bloc.dart';
import '../utils/type_effectiveness.dart';

// Retro Pokedex Colors
class _Colors {
  static const Color redDark = Color(0xFFB71C1C);
  static const Color redPrimary = Color(0xFFD32F2F);
  static const Color screenGreen = Color(0xFF9EBC9E);
  static const Color screenDark = Color(0xFF2D4F2D);
  static const Color blueLight = Color(0xFF03A9F4);
  static const Color blackFrame = Color(0xFF1A1A1A);
}

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({super.key});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  int? pokemonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && pokemonId == null) {
      pokemonId = args['pokemonId'] as int;
      context.read<PokemonBloc>().add(PokemonDetailRequested(pokemonId: pokemonId!));
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
              color: _Colors.blueLight,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const Spacer(),
          const Text(
            'POKEMON DATA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
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
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.blackFrame, width: 3),
      ),
      child: BlocBuilder<PokemonBloc, PokemonState>(
        builder: (context, state) {
          if (state.status == PokemonStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'LOADING...',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final pokemon = state.selectedPokemon;
          if (pokemon == null) {
            return const Center(
              child: Text(
                'POKEMON NOT FOUND',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
            );
          }

          final isFavorite = state.favoriteIds.contains(pokemon.id);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Main display screen
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _Colors.screenGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _Colors.blackFrame, width: 3),
                  ),
                  child: Column(
                    children: [
                      // Pokemon image and basic info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7A9A7A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _Colors.screenDark, width: 2),
                            ),
                            child: Image.network(
                              pokemon.imageUrl,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.catching_pokemon,
                                size: 80,
                                color: _Colors.screenDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pokemon.displayName.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: _Colors.screenDark,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<PokemonBloc>().add(
                                          PokemonFavoriteToggled(pokemonId: pokemon.id),
                                        );
                                      },
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : _Colors.screenDark,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  pokemon.formattedId,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: _Colors.screenDark.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Types
                                Wrap(
                                  spacing: 6,
                                  children: pokemon.types.map((type) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(type),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: _Colors.blackFrame),
                                      ),
                                      child: Text(
                                        type.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'HT: ${pokemon.heightInMeters}  WT: ${pokemon.weightInKg}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: _Colors.screenDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stats
                      _buildSectionLabel('BASE STATS'),
                      const SizedBox(height: 8),
                      _buildStatBar('HP', pokemon.hp, Colors.green),
                      _buildStatBar('ATK', pokemon.attack, Colors.red),
                      _buildStatBar('DEF', pokemon.defense, Colors.blue),
                      _buildStatBar('SP.ATK', pokemon.specialAttack, Colors.purple),
                      _buildStatBar('SP.DEF', pokemon.specialDefense, Colors.teal),
                      _buildStatBar('SPD', pokemon.speed, Colors.orange),
                    ],
                  ),
                ),

                // Type effectiveness section
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _Colors.screenGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _Colors.blackFrame, width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('TYPE MATCHUPS'),
                      const SizedBox(height: 12),
                      _buildTypeSection(
                        'WEAK AGAINST',
                        TypeEffectiveness.getWeaknesses(pokemon.types),
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildTypeSection(
                        'STRONG AGAINST',
                        TypeEffectiveness.getStrengths(pokemon.types),
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildTypeSection(
                        'RESISTANT TO',
                        TypeEffectiveness.getResistances(pokemon.types),
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: _Colors.screenDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '[ $text ]',
        style: const TextStyle(
          color: _Colors.screenGreen,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _Colors.screenDark,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: _Colors.screenDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF7A9A7A),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: _Colors.screenDark),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / 255).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection(String label, List<String> types, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        types.isEmpty
            ? Text(
                'None',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: _Colors.screenDark.withOpacity(0.5),
                ),
              )
            : Wrap(
                spacing: 4,
                runSpacing: 4,
                children: types.map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _Colors.blackFrame),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
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
