# ImmoCheck

Le projet ImmoCheck consiste à créer une application mobile permettant de réaliser un état des lieux complet : création de biens, inspection des pièces, checklist, photos et signatures, le tout sans backend.

# Prérequis

- SDK Flutter
- Android Studio ou Xcode pour les émulateurs et déploiements mobile
- Un émulateur de smartphone

# Installation

Cloner le repo

```bash
git clone https://github.com/ByggL/samueliot_immocheck.git
```

Installer les dépendances Flutter

```bash
flutter pub get
```

# Lancer l'application

## Android ou iOS

```bash
flutter run
```

## Web

```bash
flutter run -d chrome
```

# Structure des fichiers

```
└── lib/
    ├── data/
    ├── providers/
    ├── styles/
    │   └── themes.dart
    └── ui/
        ├── forms/
        ├── homepage/
        ├── report_page/
        └── main.dart
```

# Build des releases

## Android

```bash
flutter build
```

## iOS

```bash
flutter build ios
```
