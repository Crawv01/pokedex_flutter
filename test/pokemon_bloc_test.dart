import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedex_app/blocs/pokemon/pokemon_bloc.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/repositories/pokemon_repository.dart';

// Mock class for PokemonRepository
class MockPokemonRepository extends Mock implements PokemonRepository {}

void main() {
  group('PokemonBloc', () {
    late PokemonRepository pokemonRepository;
    late PokemonBloc pokemonBloc;

    // Sample test data
    final testPokemon = Pokemon(
      id: 25,
      name: 'pikachu',
      imageUrl: 'https://example.com/pikachu.png',
      types: ['electric'],
      hp: 35,
      attack: 55,
      defense: 40,
      speed: 90,
      specialAttack: 50,
      specialDefense: 50,
    );

    final testPokemonList = [
      testPokemon,
      const Pokemon(
        id: 6,
        name: 'charizard',
        imageUrl: 'https://example.com/charizard.png',
        types: ['fire', 'flying'],
        hp: 78,
        attack: 84,
        defense: 78,
        speed: 100,
        specialAttack: 109,
        specialDefense: 85,
      ),
    ];

    setUp(() {
      pokemonRepository = MockPokemonRepository();
      pokemonBloc = PokemonBloc(pokemonRepository: pokemonRepository);
    });

    tearDown(() {
      pokemonBloc.close();
    });

    test('initial state is PokemonState with status initial', () {
      expect(pokemonBloc.state.status, PokemonStatus.initial);
      expect(pokemonBloc.state.pokemonList, isEmpty);
      expect(pokemonBloc.state.favoriteIds, isEmpty);
    });

    group('PokemonListRequested', () {
      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, success] when fetching pokemon list succeeds',
        build: () {
          when(() => pokemonRepository.getPokemonList(type: null))
              .thenAnswer((_) async => testPokemonList);
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonListRequested()),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.success)
              .having((s) => s.pokemonList.length, 'pokemonList length', 2),
        ],
      );

      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, success] when fetching pokemon by type succeeds',
        build: () {
          when(() => pokemonRepository.getPokemonList(type: 'fire'))
              .thenAnswer((_) async => [testPokemonList[1]]);
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonListRequested(type: 'fire')),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.success)
              .having((s) => s.pokemonList.length, 'pokemonList length', 1)
              .having((s) => s.currentType, 'currentType', 'fire'),
        ],
      );

      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, failure] when fetching pokemon list fails',
        build: () {
          when(() => pokemonRepository.getPokemonList(type: null))
              .thenThrow(Exception('Network error'));
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonListRequested()),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('PokemonSearchRequested', () {
      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, success] when search succeeds',
        build: () {
          when(() => pokemonRepository.searchPokemon('pikachu'))
              .thenAnswer((_) async => [testPokemon]);
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonSearchRequested(query: 'pikachu')),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.success)
              .having((s) => s.pokemonList.first.name, 'first pokemon name', 'pikachu'),
        ],
      );

      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, failure] when search fails',
        build: () {
          when(() => pokemonRepository.searchPokemon('invalid'))
              .thenThrow(Exception('Not found'));
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonSearchRequested(query: 'invalid')),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.failure),
        ],
      );
    });

    group('PokemonDetailRequested', () {
      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, success] when fetching details succeeds',
        build: () {
          when(() => pokemonRepository.getPokemonDetail(25))
              .thenAnswer((_) async => testPokemon);
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonDetailRequested(pokemonId: 25)),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.success)
              .having((s) => s.selectedPokemon?.id, 'selected pokemon id', 25),
        ],
      );

      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, failure] when fetching details fails',
        build: () {
          when(() => pokemonRepository.getPokemonDetail(999))
              .thenThrow(Exception('Not found'));
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonDetailRequested(pokemonId: 999)),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.failure),
        ],
      );
    });

    group('PokemonFavoriteToggled', () {
      blocTest<PokemonBloc, PokemonState>(
        'adds pokemon to favorites when not already favorited',
        build: () {
          when(() => pokemonRepository.saveFavorites(any()))
              .thenAnswer((_) async {});
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonFavoriteToggled(pokemonId: 25)),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.favoriteIds, 'favoriteIds', contains(25)),
        ],
      );

      blocTest<PokemonBloc, PokemonState>(
        'removes pokemon from favorites when already favorited',
        build: () {
          when(() => pokemonRepository.saveFavorites(any()))
              .thenAnswer((_) async {});
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        seed: () => const PokemonState(favoriteIds: [25, 6]),
        act: (bloc) => bloc.add(const PokemonFavoriteToggled(pokemonId: 25)),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.favoriteIds, 'favoriteIds', isNot(contains(25)))
              .having((s) => s.favoriteIds, 'favoriteIds', contains(6)),
        ],
      );
    });

    group('PokemonFavoritesRequested', () {
      blocTest<PokemonBloc, PokemonState>(
        'emits [loading, success] when fetching favorites succeeds',
        build: () {
          when(() => pokemonRepository.getFavorites())
              .thenAnswer((_) async => [25]);
          when(() => pokemonRepository.getPokemonByIds([25]))
              .thenAnswer((_) async => [testPokemon]);
          return PokemonBloc(pokemonRepository: pokemonRepository);
        },
        act: (bloc) => bloc.add(const PokemonFavoritesRequested()),
        expect: () => [
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.loading),
          isA<PokemonState>()
              .having((s) => s.status, 'status', PokemonStatus.success)
              .having((s) => s.favoriteIds, 'favoriteIds', [25])
              .having((s) => s.pokemonList.length, 'pokemonList length', 1),
        ],
      );
    });
  });

  group('PokemonState', () {
    test('supports value equality', () {
      expect(
        const PokemonState(status: PokemonStatus.initial),
        const PokemonState(status: PokemonStatus.initial),
      );
    });

    test('copyWith returns new state with updated values', () {
      const original = PokemonState(status: PokemonStatus.initial);
      final copied = original.copyWith(status: PokemonStatus.loading);
      
      expect(copied.status, PokemonStatus.loading);
      expect(original.status, PokemonStatus.initial);
    });

    test('copyWith retains original values when not specified', () {
      const original = PokemonState(
        status: PokemonStatus.success,
        favoriteIds: [1, 2, 3],
      );
      final copied = original.copyWith(status: PokemonStatus.loading);
      
      expect(copied.favoriteIds, [1, 2, 3]);
    });
  });

  group('PokemonEvent', () {
    test('PokemonListRequested supports value equality', () {
      expect(
        const PokemonListRequested(type: 'fire'),
        const PokemonListRequested(type: 'fire'),
      );
    });

    test('PokemonSearchRequested props are correct', () {
      const event = PokemonSearchRequested(query: 'pikachu');
      expect(event.props, ['pikachu']);
    });

    test('PokemonDetailRequested props are correct', () {
      const event = PokemonDetailRequested(pokemonId: 25);
      expect(event.props, [25]);
    });

    test('PokemonFavoriteToggled props are correct', () {
      const event = PokemonFavoriteToggled(pokemonId: 25);
      expect(event.props, [25]);
    });
  });

  group('Pokemon Model', () {
    test('formattedId returns padded id', () {
      const pokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: '',
        types: ['electric'],
      );
      expect(pokemon.formattedId, '#025');
    });

    test('displayName capitalizes first letter', () {
      const pokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: '',
        types: ['electric'],
      );
      expect(pokemon.displayName, 'Pikachu');
    });

    test('supports value equality', () {
      const pokemon1 = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: '',
        types: ['electric'],
      );
      const pokemon2 = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: '',
        types: ['electric'],
      );
      expect(pokemon1, pokemon2);
    });
  });
}
