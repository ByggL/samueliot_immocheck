

// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';


class Room {
  final String roomName;
  final EtatsElement statut;
  final List<RoomElement> elements;

  Room({required this.roomName, required this.statut, required this.elements});
}

class RoomProvider extends ChangeNotifier{

  
}