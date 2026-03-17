import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/pokemon.dart';
import '../../repositories/pokemon_repository.dart';

part 'pokemon_event.dart';
part 'pokemon_state.dart';

/// PokemonBloc handles Pokemon data state management
/// following the Bloc architectural pattern
class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final PokemonRepository pokemonRepository;

  PokemonBloc({required this.pokemonRepository}) : super(const PokemonState()) {
    // Register event handlers
    on<PokemonListRequested>(_onListRequested);
    on<PokemonSearchRequested>(_onSearchRequested);
    on<PokemonDetailRequested>(_onDetailRequested);
    on<PokemonFavoriteToggled>(_onFavoriteToggled);
    on<PokemonFavoritesRequested>(_onFavoritesRequested);
  }

  /// Handles Pokemon list request event
  Future<void> _onListRequested(
    PokemonListRequested event,
    Emitter<PokemonState> emit,
  ) async {
    emit(state.copyWith(status: PokemonStatus.loading));
    
    try {
      final pokemonList = await pokemonRepository.getPokemonList(
        type: event.type,
      );
      emit(state.copyWith(
        status: PokemonStatus.success,
        pokemonList: pokemonList,
        currentType: event.type,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PokemonStatus.failure,
        errorMessage: 'Failed to load Pokemon: ${e.toString()}',
      ));
    }
  }

  /// Handles Pokemon search request event
  Future<void> _onSearchRequested(
    PokemonSearchRequested event,
    Emitter<PokemonState> emit,
  ) async {
    emit(state.copyWith(status: PokemonStatus.loading));
    
    try {
      final results = await pokemonRepository.searchPokemon(event.query);
      emit(state.copyWith(
        status: PokemonStatus.success,
        pokemonList: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PokemonStatus.failure,
        errorMessage: 'Search failed: ${e.toString()}',
      ));
    }
  }

  /// Handles Pokemon detail request event
  Future<void> _onDetailRequested(
    PokemonDetailRequested event,
    Emitter<PokemonState> emit,
  ) async {
    emit(state.copyWith(status: PokemonStatus.loading));
    
    try {
      final pokemon = await pokemonRepository.getPokemonDetail(event.pokemonId);
      emit(state.copyWith(
        status: PokemonStatus.success,
        selectedPokemon: pokemon,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PokemonStatus.failure,
        errorMessage: 'Failed to load details: ${e.toString()}',
      ));
    }
  }

  /// Handles favorite toggle event
  Future<void> _onFavoriteToggled(
    PokemonFavoriteToggled event,
    Emitter<PokemonState> emit,
  ) async {
    final currentFavorites = List<int>.from(state.favoriteIds);
    
    if (currentFavorites.contains(event.pokemonId)) {
      currentFavorites.remove(event.pokemonId);
    } else {
      currentFavorites.add(event.pokemonId);
    }
    
    await pokemonRepository.saveFavorites(currentFavorites);
    emit(state.copyWith(favoriteIds: currentFavorites));
  }

  /// Handles favorites list request event
  Future<void> _onFavoritesRequested(
    PokemonFavoritesRequested event,
    Emitter<PokemonState> emit,
  ) async {
    emit(state.copyWith(status: PokemonStatus.loading));
    
    try {
      final favoriteIds = await pokemonRepository.getFavorites();
      final favorites = await pokemonRepository.getPokemonByIds(favoriteIds);
      emit(state.copyWith(
        status: PokemonStatus.success,
        pokemonList: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PokemonStatus.failure,
        errorMessage: 'Failed to load favorites: ${e.toString()}',
      ));
    }
  }
}
