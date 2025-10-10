
import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class RoomElement {
  final String elementID;
  final RoomElements elementName;
  final String commentaire;
  final EtatsElement statut;
  final List<dynamic> elementPicture;

  RoomElement({required this.commentaire, required this.statut, required this.elementPicture, required this.elementName, required this.elementID});

  Map<String, dynamic> toJson() => {
    'elementID': elementID,
    'elementName': elementName.index,
    'commentaire': commentaire,
    'statut': statut.index,
    'elementPicture': elementPicture,
  };

  factory RoomElement.fromJson(Map<String, dynamic> json) => RoomElement(
    elementID: json['elementID'],
    elementName: RoomElements.values[json['elementName']],
    commentaire: json['commentaire'],
    statut: EtatsElement.values[json['statut']],
    elementPicture: List<dynamic>.from(json['elementPicture'] ?? []),
  );
}

class RoomElementProvider extends ChangeNotifier {
  final List<RoomElement> _elements = [];
  // Requires flutter_secure_storage in pubspec.yaml
  // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  // import 'dart:convert';
  final _storage = FlutterSecureStorage();

  List<RoomElement> get elements => List.unmodifiable(_elements);

  void addElement(RoomElement element) {
    _elements.add(element);
    notifyListeners();
  }

  void removeElement(String elementID) {
    _elements.removeWhere((e) => e.elementID == elementID);
    notifyListeners();
  }

  void updateElement(RoomElement updated) {
    int idx = _elements.indexWhere((e) => e.elementID == updated.elementID);
    if (idx != -1) {
      _elements[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> saveElements(String roomKey) async {
    String jsonData = jsonEncode(_elements.map((e) => e.toJson()).toList());
    await _storage.write(key: 'elements_$roomKey', value: jsonData);
  }

  Future<void> loadElements(String roomKey) async {
    String? jsonData = await _storage.read(key: 'elements_$roomKey');
    if (jsonData != null) {
      List<dynamic> decoded = jsonDecode(jsonData);
      _elements
        ..clear()
        ..addAll(decoded.map((e) => RoomElement.fromJson(e)));
      notifyListeners();
    }
  }
}