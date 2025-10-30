

import 'package:flutter/foundation.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/property_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class Rapport extends Property {
  final EtatsRapport statutRapport;
  final List<Uint8List?> signature;
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
    'signature': signature.map((s) => base64Encode(s!)).toList(),
    };

  factory Rapport.fromJson(Map<String, dynamic> json) => Rapport(
    nom: json['nom'],
    adresse: json['adresse'],
    roomList: (json['roomList'] as List).map((r) => Room.fromJson(r)).toList(),
    propertyType: PropertyTypes.values[json['propertyType']],
    propertyId: json['propertyId'],
    creationDate: DateTime.parse(json['creationDate']),
    statutRapport: EtatsRapport.values[json['statutRapport']],
    signature: (json['signature'] as List).map((s) => Uint8List.fromList(base64Decode(s))).toList(),
    );
  }

class RapportProvider extends ChangeNotifier{
  
  final _storage = FlutterSecureStorage();

  final List<Rapport> _properties = [];

  List<Property> get properties => List.unmodifiable(_properties);

  // Global functions

  void addRapportGlobal(Rapport propertyToAdd){
    _properties.add(propertyToAdd);
  }

  Rapport? getPropertyById(String id){
    for (Rapport property in _properties){
        if (property.propertyId == id){
          return property;
        }
    } 
    return null;
  }

  Rapport? getPropertyByRoomId(String roomId){
    for (var property in _properties) {
      for (var room in property.roomList) {
        if (room.roomId == roomId) {
          return property;
        }
      }
    }
    return null;
  }

  void updateRapportGlobal(Rapport propertyToUpdate){
    int index = _properties.indexWhere((p) => p.propertyId == propertyToUpdate.propertyId);
    if (index != -1) {
      _properties[index] = propertyToUpdate;
      notifyListeners();
    }
  }

  Rapport? getRapportById(String id){
    for (Rapport property in _properties){
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
    // print("Saved rapports");
    // for (var p in _properties) {
    //   if (p is Rapport) {
    //     print(jsonEncode(p.toJson()));
    //   } else {
    //     print(p);
    //   }
    // }
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

  void validateRapport(Rapport report, List<Uint8List?> signatures){
    EtatsRapport newEtat ;
    report.statutRapport == EtatsRapport.enCours ? newEtat=EtatsRapport.termine:newEtat=EtatsRapport.enCours;

    int index = _properties.indexWhere((p) => p.propertyId == report.propertyId);

    
    if (index != -1) {
      Rapport newRapport = Rapport(
        propertyId: report.propertyId,
        nom: report.nom,
        adresse: report.adresse,
        roomList: report.roomList,
        propertyType: report.propertyType,
        creationDate: report.creationDate,
        signature: signatures,
        statutRapport: newEtat, 
      );

      _properties[index] = newRapport;
      notifyListeners();
      saveRapports();
    }
  }

  void deleteRoomFromRapport(String propertyId, String roomId) {
    Property? rapport = getRapportById(propertyId);
    if (rapport == null) return;
    
    rapport.roomList.removeWhere((r) => r.roomId == roomId);
    
    notifyListeners();
    saveRapports();
  }

  void removeRapport(Property propertyToRemove){
    _properties.removeWhere((p) => p.propertyId == propertyToRemove.propertyId);
    notifyListeners();
    // Also save after removal
    saveRapports();
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
    Rapport? property = getRapportById(propertyId);
    if (property == null) {
      throw Exception('No property found with this ID');
    }
    property.roomList.add(roomToAdd);
    // print("Adding to global");
    updateRapportGlobal(property);
    notifyListeners(); // Tell widgets something changed
    saveRapports();   // Persist the change
    // print("Saved???");
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
    
    Rapport? propertyUpdated = getPropertyByRoomId(roomId);
    if (propertyUpdated != null) {
      updateRapportGlobal(propertyUpdated);
    }
    // Notify all listeners and persist the change.
    notifyListeners();
    saveRapports();
  }

  void deleteElementFromRoom(String roomId, String elementId) {
    Room? room = _getRoomById(roomId);
    if (room == null) return;
    
    room.elements.removeWhere((e) => e.elementID == elementId);
    
    Rapport? propertyUpdated = getPropertyByRoomId(roomId);
    if (propertyUpdated != null) {
      updateRapportGlobal(propertyUpdated);
    }
    notifyListeners();
    saveRapports();
  }
  
  void updateRoomInRapport(String propertyId, Room updatedRoom) {
    Rapport? property = getRapportById(propertyId);
    if (property == null) {
      throw Exception('No property found with this ID');
    }

    int roomIndex = property.roomList.indexWhere((r) => r.roomId == updatedRoom.roomId);
    // print('Updating room with ID: ${updatedRoom.roomId}, name: ${updatedRoom.roomTrueName}, roomType: ${updatedRoom.roomName}');
    if (roomIndex != -1) {
      // print('?');
      property.roomList[roomIndex] = updatedRoom;
      updateRapportGlobal(property);
      notifyListeners();
      saveRapports();
    }
  }

  void changeRoomStatus(Room roomToCheck){
    EtatsElement newEtat ;
    roomToCheck.statut == EtatsElement.aReparer ? newEtat=EtatsElement.ok:newEtat=EtatsElement.aReparer;

    for (int i = 0; i < _properties.length; i++) {
    var rapport = _properties[i];
    int roomIndex = rapport.roomList.indexWhere((r) => r.roomId == roomToCheck.roomId);

      if (roomIndex != -1) {
        // Create a NEW Room object with the updated status
        Room newRoom = Room(
            roomId: roomToCheck.roomId,
            roomTrueName: roomToCheck.roomTrueName,
            roomName: roomToCheck.roomName,
            statut: newEtat, // <<< The new status is applied here
            elements: roomToCheck.elements,
        );

        // Replace the old Room object with the new one in the master list
        rapport.roomList[roomIndex] = newRoom;
      
      Rapport? propertyUpdated = getPropertyByRoomId(newRoom.roomId);
      if (propertyUpdated != null) {
        updateRapportGlobal(propertyUpdated);
      }
      notifyListeners();
      saveRapports();
      }
    }
  }



}