import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/property_provider.dart';

class Rapport extends property {
  final EtatsRapport statutRapport;
  final String signature;
  final DateTime creationDate;

  Rapport({
    required super.nom,
    required super.adresse,
    required super.roomList,
    required super.propertyType,
    required this.statutRapport,
    required this.signature,
    required this.creationDate,
  });
}

class RapportProvider extends ChangeNotifier {}
