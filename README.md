# PokeDex Mobile Application

A Flutter mobile application for browsing Pokemon information, built using the Bloc architectural pattern.

## Project Structure

```
lib/
├── main.dart                    # App entry point with MaterialApp and routing
├── blocs/
│   ├── auth/
│   │   ├── auth_bloc.dart       # Authentication business logic
│   │   ├── auth_event.dart      # Auth events
│   │   └── auth_state.dart      # Auth states
│   └── pokemon/
│       ├── pokemon_bloc.dart    # Pokemon data business logic
│       ├── pokemon_event.dart   # Pokemon events
│       └── pokemon_state.dart   # Pokemon states
├── models/
│   └── pokemon.dart             # Pokemon data model
├── repositories/
│   ├── auth_repository.dart     # Authentication data access
│   └── pokemon_repository.dart  # Pokemon API data access
└── screens/
    ├── login_screen.dart        # Login/Sign up screen
    ├── home_screen.dart         # Main screen with search and browse
    ├── pokemon_list_screen.dart # Filtered Pokemon list
    ├── pokemon_detail_screen.dart # Pokemon details view
    └── favorites_screen.dart    # Saved favorites
```

## Features

- **MaterialApp** widget as root with Material Design 3
- **Bloc Architecture** using flutter_bloc package
- **Named Routes** for navigation between screens
- **AppBar** on all screens
- **PokeAPI** integration for Pokemon data
- **Local Storage** for favorites using shared_preferences

## Setup Instructions

1. Ensure Flutter is installed and configured
2. Clone/extract this project
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to launch in simulator/emulator

## Dependencies

- flutter_bloc: ^8.1.3 - State management
- equatable: ^2.0.5 - Value equality
- http: ^1.1.0 - API requests
- cached_network_image: ^3.3.0 - Image caching
- shared_preferences: ^2.2.2 - Local storage

## Screens

1. **Login Screen** - User authentication with username/password
2. **Home Screen** - Search bar, type filters, popular Pokemon grid
3. **Pokemon List** - Filtered list by type
4. **Pokemon Detail** - Stats, types, abilities, favorites
5. **Favorites** - Saved Pokemon list

## Bloc Components

- **AuthBloc** - Handles login, logout, authentication state
- **PokemonBloc** - Handles Pokemon list, search, details, favorites

## CSC3317 Week 5 Requirements Met

1. ✅ Application frame demonstrable via Simulator
2. ✅ Application includes AppBar
3. ✅ Application includes skeleton screens
4. ✅ Application includes routing (named routes)
5. ✅ Application abides by Bloc architectural pattern
