


// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class Property {
  final String propertyId;
  final String nom;
  final String adresse;
  final List<Room> roomList;
  final PropertyTypes propertyType;

  Property({required this.nom, required this.adresse, required this.roomList,required this.propertyType, required this.propertyId});

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'adresse': adresse,
    'roomList': roomList.map((r) => r.toJson()).toList(),
    'propertyType': propertyType.index,
  };

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    nom: json['nom'],
    adresse: json['adresse'],
    roomList: (json['roomList'] as List).map((r) => Room.fromJson(r)).toList(),
    propertyType: PropertyTypes.values[json['propertyType']],
    propertyId: json['propertyId']
  );
}

class PropertyProvider extends ChangeNotifier{
  final _storage = FlutterSecureStorage();

  List<Property> _properties = [];

  List<Property> get properties => List.unmodifiable(_properties);


  void addPropertyGlobal(Property propertyToAdd){
    _properties.add(propertyToAdd);
  }

  Property? getPropertyById(String id){
    for (Property property in _properties){
        if (property.propertyId == id){
          return property;
        }
    } 
    return null;
  }

  void addRoomToProperty(String propertyId,Room roomToAdd){
    Property? property = getPropertyById(propertyId);
    if (property==null){
      throw Exception('No property found with this ID');
    }
    property.roomList.add(roomToAdd);
  }

  // Save all properties to storage
  Future<void> saveProperties() async {
    await _storage.write(
      key: 'properties_list',
      value: jsonEncode(_properties.map((p) => p.toJson()).toList()),
    );
    notifyListeners();
  }


  // Load all properties from storage
  Future<void> loadProperties() async {
    String? data = await _storage.read(key: 'properties_list');
    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);
      print(decoded);
      _properties = decoded.map((p) => Property.fromJson(p)).toList();
      notifyListeners();
    }
  }

}