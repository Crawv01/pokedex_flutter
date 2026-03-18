# Pokédex Flutter App

A Flutter mobile application for browsing Pokémon information, built with the BLoC architectural pattern, PokéAPI integration, type filtering, pagination, and persistent login via SharedPreferences.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![PokéAPI](https://img.shields.io/badge/PokéAPI-EF5350?style=flat)

---

## ✨ Features

- **BLoC Architecture** — Full separation of UI and business logic using `flutter_bloc`
- **PokéAPI Integration** — Live Pokémon data including stats, types, abilities, and sprites
- **Type Filtering** — Browse Pokémon by type with paginated list views
- **Search** — Search Pokémon by name from the home screen
- **Favorites** — Save and view favorite Pokémon using local storage
- **Persistent Login** — Authentication state persisted across sessions with `shared_preferences`
- **Image Caching** — Pokémon sprites cached with `cached_network_image` for smooth scrolling
- **Material Design 3** — Clean UI with named routes and consistent AppBar navigation

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State Management | flutter_bloc |
| API | PokéAPI |
| Local Storage | shared_preferences |
| Image Caching | cached_network_image |
| HTTP | http package |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed and configured
- Android emulator, iOS simulator, or physical device

### Installation

```bash
git clone https://github.com/Crawv01/pokedex_flutter.git
cd pokedex_flutter
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point with MaterialApp and routing
├── blocs/
│   ├── auth/
│   │   ├── auth_bloc.dart           # Authentication business logic
│   │   ├── auth_event.dart          # Auth events
│   │   └── auth_state.dart          # Auth states
│   └── pokemon/
│       ├── pokemon_bloc.dart        # Pokémon data business logic
│       ├── pokemon_event.dart       # Pokémon events
│       └── pokemon_state.dart       # Pokémon states
├── models/
│   └── pokemon.dart                 # Pokémon data model
├── repositories/
│   ├── auth_repository.dart         # Authentication data access
│   └── pokemon_repository.dart      # PokéAPI data access
└── screens/
    ├── login_screen.dart            # Login and sign up
    ├── home_screen.dart             # Search and browse
    ├── pokemon_list_screen.dart     # Type-filtered Pokémon list
    ├── pokemon_detail_screen.dart   # Stats, types, abilities
    └── favorites_screen.dart        # Saved favorites
```

---

## 📦 Dependencies

```yaml
flutter_bloc: ^8.1.3       # BLoC state management
equatable: ^2.0.5          # Value equality for BLoC states
http: ^1.1.0               # PokéAPI requests
cached_network_image: ^3.3.0  # Sprite image caching
shared_preferences: ^2.2.2    # Persistent login storage
```

---

## 🗺 Roadmap

- [ ] Retro Pokédex UI theme
- [ ] Evolution chain display
- [ ] Compare two Pokémon side by side
- [ ] Offline mode with local cache

---

## 📄 License

MIT
