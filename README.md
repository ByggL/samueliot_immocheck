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

## Build en local 

### Android

```bash
flutter build
```

### iOS

```bash
flutter build ios
```

## Build CI et release github

Pour lancer une release sur le repo github, il suffit de push un tag de la forme v*.*.* non-déjà utilisé sur la branche main du repo et une github action le fera automatiquement: exemple pour une v1.2.3 :

```bash
git tag v1.2.3
git push origin v1.2.3
```

Après l'execution de la github action, la release sera disponible sur le repo. 
