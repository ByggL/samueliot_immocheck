

import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/property_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class Rapport extends Property {
  final EtatsRapport statutRapport;
  final String signature;
  final DateTime creationDate;

  Rapport({
    required super.nom,
    required super.adresse,
    required super.roomList,
    required super.propertyType,
    required super.propertyId,
    required this.creationDate,
    required this.statutRapport,
    required this.signature,
  });

  @override
  Map<String, dynamic> toJson() => {
    'propertyId': propertyId, 
    'creationDate': creationDate.toIso8601String(),
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
    creationDate: DateTime.parse(json['creationDate']),
    statutRapport: EtatsRapport.values[json['statutRapport']],
    signature: json['signature'],
  );
}

class RapportProvider extends ChangeNotifier{
  final _storage = FlutterSecureStorage();

  List<Property> _properties = [];

  List<Property> get properties => List.unmodifiable(_properties);


  void addRapportGlobal(Property propertyToAdd){
    _properties.add(propertyToAdd);
  }

  Property? getRapportById(String id){
    for (Property property in _properties){
        if (property.propertyId == id){
          return property;
        }
    } 
    return null;
  }


  // Save all properties to storage
  Future<void> saveRapports() async {
    await _storage.write(
      key: 'properties_list',
      value: jsonEncode(_properties.map((p) => p.toJson()).toList()),
    );
    notifyListeners();
  }


  // Load all properties from storage
  Future<void> loadRapports() async {
    String? data = await _storage.read(key: 'properties_list');
    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);
      _properties.clear();
      _properties.addAll(decoded.map((p) => Rapport.fromJson(p)).toList());
      notifyListeners();
    }
  }


  // ROOM FUNCTIONS 
  Room? _getRoomById(String roomId) {
    for (var property in _properties.cast<Rapport>()) {
      for (var room in property.roomList) {
        if (room.roomId == roomId) {
          return room;
        }
      }
    }
    return null;
  }

  void addRoomToRapport(String propertyId, Room roomToAdd) {
    Property? property = getRapportById(propertyId);
    if (property == null) {
      throw Exception('No property found with this ID');
    }
    property.roomList.add(roomToAdd);
    notifyListeners(); // Tell widgets something changed
    saveRapports();   // Persist the change
  }

    void addElementToRoom(String roomId, RoomElement roomElementToAdd) {
      Room? room = _getRoomById(roomId);

      if (room == null) {
        throw Exception('No room found with this ID');
      }

      // Since the original Room object is part of the stored list, modifying it works.
      room.elements.add(roomElementToAdd);

      notifyListeners(); // Tell widgets something changed
      saveRapports();   // Persist the change
    }
}