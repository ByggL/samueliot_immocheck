


import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/property_provider.dart';

class Room {
  final String roomId;
  final RoomTypes roomName;
  final EtatsElement statut;
  final List<RoomElement> elements;

  Room({
    required this.roomName,
    required this.statut,
    List<RoomElement>? elements,
    required this.roomId,
  }) : elements = elements ?? Room.defaultElementsForRoomType(roomName, roomId);

static List<RoomElement> defaultElementsForRoomType(RoomTypes type, String roomId) {
    print(type);
    // Helper to create a RoomElement with minimal info
    RoomElement makeElement(RoomElements el) => RoomElement(
      elementID: '${roomId}_${el.name}',
      elementName: el,
      commentaire: '',
      statut: EtatsElement.ok,
      elementPicture: [],
    );

    switch (type) {
      case RoomTypes.entrance:
        return [
          makeElement(RoomElements.door),
          makeElement(RoomElements.walls),
          makeElement(RoomElements.floor),
          makeElement(RoomElements.ceiling),
          makeElement(RoomElements.lighting),
          makeElement(RoomElements.electricalOutlets),
        ];

      case RoomTypes.livingRoom:
        return [
          makeElement(RoomElements.walls),
          makeElement(RoomElements.floor),
          makeElement(RoomElements.ceiling),
          makeElement(RoomElements.window),
          makeElement(RoomElements.lighting),
          makeElement(RoomElements.heating),
          makeElement(RoomElements.electricalOutlets),
          makeElement(RoomElements.balconyOrTerrace),
          makeElement(RoomElements.fireplace),
        ];

      case RoomTypes.kitchen:
        return [
          makeElement(RoomElements.walls),
          makeElement(RoomElements.floor),
          makeElement(RoomElements.ceiling),
          makeElement(RoomElements.window),
          makeElement(RoomElements.lighting),
          makeElement(RoomElements.electricalOutlets),
          makeElement(RoomElements.ventilation),
          makeElement(RoomElements.countertop),
          makeElement(RoomElements.cabinets),
          makeElement(RoomElements.sink),
          makeElement(RoomElements.stove),
          makeElement(RoomElements.refrigeratorSpace),
        ];

      case RoomTypes.bathroom:
        return [
          makeElement(RoomElements.walls),
          makeElement(RoomElements.floor),
          makeElement(RoomElements.ceiling),
          makeElement(RoomElements.window),
          makeElement(RoomElements.lighting),
          makeElement(RoomElements.ventilation),
          makeElement(RoomElements.sinkVanity),
          makeElement(RoomElements.bathtubOrShower),
          makeElement(RoomElements.heating),
        ];

      case RoomTypes.bedroom:
        return [
          makeElement(RoomElements.walls),
          makeElement(RoomElements.floor),
          makeElement(RoomElements.ceiling),
          makeElement(RoomElements.window),
          makeElement(RoomElements.lighting),
          makeElement(RoomElements.heating),
          makeElement(RoomElements.electricalOutlets),
          makeElement(RoomElements.wardrobe),
        ];

      case RoomTypes.wc:
        return [
          makeElement(RoomElements.walls),
          makeElement(RoomElements.floor),
          makeElement(RoomElements.ceiling),
          makeElement(RoomElements.lighting),
          makeElement(RoomElements.toilets),
          makeElement(RoomElements.ventilation),
        ];
        
      case RoomTypes.other:
        return [
          makeElement(RoomElements.walls),
          makeElement(RoomElements.floor),
          makeElement(RoomElements.ceiling),
          makeElement(RoomElements.window),
          makeElement(RoomElements.door),
          makeElement(RoomElements.lighting),
          makeElement(RoomElements.electricalOutlets),
        ];
    }
  }

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