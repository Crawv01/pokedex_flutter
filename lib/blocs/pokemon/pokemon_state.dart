part of 'pokemon_bloc.dart';

/// Enum representing Pokemon loading status
enum PokemonStatus { initial, loading, success, failure }

/// State class for Pokemon data
class PokemonState extends Equatable {
  final PokemonStatus status;
  final List<Pokemon> pokemonList;
  final Pokemon? selectedPokemon;
  final List<int> favoriteIds;
  final String? errorMessage;
  final String? currentType;

  const PokemonState({
    this.status = PokemonStatus.initial,
    this.pokemonList = const [],
    this.selectedPokemon,
    this.favoriteIds = const [],
    this.errorMessage,
    this.currentType,
  });

  /// Creates a copy of the state with updated values
  PokemonState copyWith({
    PokemonStatus? status,
    List<Pokemon>? pokemonList,
    Pokemon? selectedPokemon,
    List<int>? favoriteIds,
    String? errorMessage,
    String? currentType,
  }) {
    return PokemonState(
      status: status ?? this.status,
      pokemonList: pokemonList ?? this.pokemonList,
      selectedPokemon: selectedPokemon ?? this.selectedPokemon,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: errorMessage ?? this.errorMessage,
      currentType: currentType ?? this.currentType,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pokemonList,
        selectedPokemon,
        favoriteIds,
        errorMessage,
        currentType,
      ];
}
