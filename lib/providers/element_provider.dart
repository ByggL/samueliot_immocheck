

// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';

class RoomElement {
  final String commentaire;
  final EtatsElement statut;
  final List<dynamic> elementPicture;

  RoomElement({required this.commentaire, required this.statut, required this.elementPicture});
}

class RoomElementProvider extends ChangeNotifier{


}