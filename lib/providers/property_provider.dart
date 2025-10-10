

// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';

class property {
  final String nom;
  final String adresse;
  final List<Room> roomList;
  final PropertyTypes propertyType;

  property({required this.nom, required this.adresse, required this.roomList,required this.propertyType,});
}

class property_provider extends ChangeNotifier{

  
}