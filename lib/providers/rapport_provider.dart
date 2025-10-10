

import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/property_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class Rapport extends Property {
  final EtatsRapport statutRapport;
  final String signature;

  Rapport({
    required super.nom,
    required super.adresse,
    required super.roomList,
    required super.propertyType,
    required super.propertyId,
    required this.statutRapport,
    required this.signature,
  });

  @override
  Map<String, dynamic> toJson() => {
    'nom': nom,
    'adresse': adresse,
    'roomList': roomList.map((r) => r.toJson()).toList(),
    'propertyType': propertyType.index,
    'statutRapport': statutRapport.index,
    'signature': signature,
  };

  factory Rapport.fromJson(Map<String, dynamic> json) => Rapport(
    nom: json['nom'],
    adresse: json['adresse'],
    roomList: (json['roomList'] as List).map((r) => Room.fromJson(r)).toList(),
    propertyType: PropertyTypes.values[json['propertyType']],
    propertyId: json['propertyId'],
    statutRapport: EtatsRapport.values[json['statutRapport']],
    signature: json['signature'],
  );
}

class RapportProvider extends ChangeNotifier{
  final _storage = FlutterSecureStorage();

  // Save rapport
  Future<void> saveRapport(Rapport rapport) async {
    await _storage.write(key: 'rapport_${rapport.nom}', value: jsonEncode(rapport.toJson()));
  }

  // Load rapport
  Future<Rapport?> loadRapport(String nom) async {
    String? data = await _storage.read(key: 'rapport_$nom');
    if (data != null) {
      return Rapport.fromJson(jsonDecode(data));
    }
    return null;
  }
}