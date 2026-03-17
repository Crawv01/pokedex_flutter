part of 'pokemon_bloc.dart';

/// Abstract base class for all Pokemon events
abstract class PokemonEvent extends Equatable {
  const PokemonEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load Pokemon list
class PokemonListRequested extends PokemonEvent {
  final String? type;
  
  const PokemonListRequested({this.type});

  @override
  List<Object?> get props => [type];
}

/// Event triggered to search for a Pokemon
class PokemonSearchRequested extends PokemonEvent {
  final String query;

  const PokemonSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event triggered to load Pokemon details
class PokemonDetailRequested extends PokemonEvent {
  final int pokemonId;

  const PokemonDetailRequested({required this.pokemonId});

  @override
  List<Object?> get props => [pokemonId];
}

/// Event triggered to toggle favorite status
class PokemonFavoriteToggled extends PokemonEvent {
  final int pokemonId;

  const PokemonFavoriteToggled({required this.pokemonId});

  @override
  List<Object?> get props => [pokemonId];
}

/// Event triggered to load favorites
class PokemonFavoritesRequested extends PokemonEvent {
  const PokemonFavoritesRequested();
}
