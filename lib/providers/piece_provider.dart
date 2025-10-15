


import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/property_provider.dart';

class Room {
  final String roomId;
  final RoomTypes roomName;
  final EtatsElement statut;
  final List<RoomElement> elements;

  Room({required this.roomName, required this.statut, required this.elements, required this.roomId});

  Map<String, dynamic> toJson() => {
    'id': roomId,
    'roomName': roomName.index,
    'statut': statut.index,
    'elements': elements.map((e) => e.toJson()).toList(),
  };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    roomId: json['id'],
    roomName: RoomTypes.values[json['roomName']],
    statut: EtatsElement.values[json['statut']],
    elements: (json['elements'] as List).map((e) => RoomElement.fromJson(e)).toList(),
  );
}

class RoomProvider extends ChangeNotifier{

  Future<Room?> getRoomById(String roomId) async {
    PropertyProvider provider = PropertyProvider();
    await provider.loadProperties();
    List<Property> allProperties = provider.properties;
    for (Property property in allProperties){
      for (Room room in property.roomList){
        if (room.roomId == roomId){
          return room;
        }
      }
    } 
    return null;
  }

  List<Room>? getRoomsByPropertyId(String propertyId){
    PropertyProvider provider = PropertyProvider();
    provider.loadProperties();
    List<Property> allProperties = provider.properties;
    for (Property property in allProperties){
        if (property.propertyId == propertyId){
          return property.roomList;
        }
    } 
    return null;
  }
  
  void addElementToRoom(String roomId,RoomElement roomElementToAdd) async{
    Room? room = await getRoomById(roomId);
    
    if (room==null){
      throw Exception('No room found with this ID');
    }
    room.elements.add(roomElementToAdd);
  }

}