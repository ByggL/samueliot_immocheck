

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

  void saveElementToRoom(String roomId, RoomElement newOrUpdatedElement) {
    Room? room = _getRoomById(roomId);

    if (room == null) {
      throw Exception('Room not found with ID: $roomId');
    }

    // Check if an element with this ID already exists (Update logic)
    int index = room.elements.indexWhere((e) => e.elementID == newOrUpdatedElement.elementID);

    if (index != -1) {
      // It exists: REPLACE the old element with the updated one.
      room.elements[index] = newOrUpdatedElement;
    } else {
      // It's new: ADD the new element.
      room.elements.add(newOrUpdatedElement);
    }
    
    // Notify all listeners and persist the change.
    notifyListeners();
    saveRapports();
  }

  void deleteElementFromRoom(String roomId, String elementId) {
    Room? room = _getRoomById(roomId);
    if (room == null) return;
    
    room.elements.removeWhere((e) => e.elementID == elementId);
    
    notifyListeners();
    saveRapports();
  }
  
  void deleteRoomFromRapport(String propertyId, String roomId) {
    Property? rapport = getRapportById(propertyId);
    if (rapport == null) return;
    
    rapport.roomList.removeWhere((r) => r.roomId == roomId);
    
    notifyListeners();
    saveRapports();
  }

  void changeRoomStatus(Room roomToCheck){
    EtatsElement etatRoom = roomToCheck.statut;
    etatRoom == EtatsElement.aReparer ? etatRoom=EtatsElement.aReparer:etatRoom=EtatsElement.ok;

    notifyListeners();
    saveRapports();
  }

  void removeRapport(Property propertyToRemove){
    _properties.removeWhere((p) => p.propertyId == propertyToRemove.propertyId);
    notifyListeners();
    // Also save after removal
    saveRapports();
  }

}