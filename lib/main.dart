import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/pokemon/pokemon_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pokemon_list_screen.dart';
import 'screens/pokemon_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'repositories/auth_repository.dart';
import 'repositories/pokemon_repository.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<PokemonRepository>(
          create: (context) => PokemonRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<PokemonBloc>(
            create: (context) => PokemonBloc(
              pokemonRepository: context.read<PokemonRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'PokeDex',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 2,
            ),
          ),
          // Define named routes for navigation
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/pokemon-list': (context) => const PokemonListScreen(),
            '/pokemon-detail': (context) => const PokemonDetailScreen(),
            '/favorites': (context) => const FavoritesScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}
