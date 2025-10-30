// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'dart:io';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';


class ElementInspectionFormPage extends StatefulWidget {
  final RoomElement? element;
  final Room? roomToAddTo;
  const ElementInspectionFormPage({super.key, this.element, required this.roomToAddTo});

  static Route<void> route(RoomElement? element, Room? roomToAddTo) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/elementsInspectionForm'),
      builder: (_) => ElementInspectionFormPage(element: element, roomToAddTo: roomToAddTo),
    );
  }

  @override
  State<ElementInspectionFormPage> createState() =>
      _ElementInspectionFormPageState();
}

class _ElementInspectionFormPageState extends State<ElementInspectionFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _comment = '';
  String _elementId='';
  RoomElements _elementName = RoomElements.floor;
  EtatsElement _status = EtatsElement.ok;
  List<XFile?> _images = [];


  Future<void> _selectImageSourceAndPick() async {
      if (_images.length >= 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 3 photos atteintes. Supprimez une image pour en ajouter une nouvelle.'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
        return;
      }

      ImageSource? chosenSource;
      // Vérifie si la plateforme est mobile (Android/iOS)
      bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS); //

      if (!isMobile) {
        // Plateforme non mobile : bascule automatique vers la Galerie et informe l'utilisateur.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Caméra non supportée sur cette plateforme. Ouverture de la Galerie.'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
        chosenSource = ImageSource.gallery;
        
      } else {
        // Plateforme mobile : Affiche la boîte de dialogue.
        chosenSource = await showDialog<ImageSource>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sélectionner la source'),
              content: const Text(
                'Si la caméra ne fonctionne pas, la Galerie est recommandée.', //
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: const Text('Caméra'), // L'option n'est pas masquée, mais l'utilisateur est informé de la limitation.
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: const Text('Galerie'),
                ),
              ],
            );
          },
        );
      }

      if (chosenSource == null) return; // L'utilisateur a annulé

      ImageSource sourceToUse = chosenSource;
      XFile? image;
      final ImagePicker picker = ImagePicker();

      // 1. Gestion des permissions et tentative pour la Caméra
      if (sourceToUse == ImageSource.camera) {
        PermissionStatus status = await Permission.camera.request(); // Demande de permission Caméra

        if (status.isGranted) {
          try {
            image = await picker.pickImage(source: ImageSource.camera);
          } catch (e) {
            // Échec de la caméra (ex: bug émulateur). Bascule automatique vers la Galerie.
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Échec de la caméra. Bascule automatique vers la Galerie.'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
            }
            sourceToUse = ImageSource.gallery; // Changement de source pour la tentative de repli
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission Caméra refusée. Veuillez utiliser la Galerie.'),
              duration: Duration(milliseconds: 1500),
            ),
          );
          return;
        }
      }

      // 2. Tentative de sélection depuis la Galerie (choisie initialement, ou après échec caméra)
      if (sourceToUse == ImageSource.gallery && image == null) {
        PermissionStatus status;
        if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
          status = PermissionStatus.granted; // Pas de vérification nécessaire sur Desktop/Web
        } else {
          status = await Permission.photos.request(); // Demande de permission Photos/Galerie
        }

        if (status.isGranted) {
          image = await picker.pickImage(source: ImageSource.gallery);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission Galerie refusée. Impossible de sélectionner une image.'),
              duration: Duration(milliseconds: 1500),
            ),
          );
          return;
        }
      }
      
      // 3. Traitement final de l'image
      if (image != null) {
        if (mounted) {
          setState(() {
            _images.add(image);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo ajoutée depuis la ${chosenSource == ImageSource.camera && sourceToUse != ImageSource.gallery ? "Caméra" : "Galerie"}'),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sélection d\'image annulée.'),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
      }
    }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _submit(){

    
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();


        if (_comment ==''){
          _comment = 'RAS';
        }

        RoomElement elementToAdd =
          RoomElement(
            commentaire: _comment ,
            elementID: _elementId ,
            elementPicture:_images,
            statut: _status,
            elementName:_elementName,
            );
          


        context.read<RapportProvider>()
        .saveElementToRoom(
          widget.roomToAddTo!.roomId,
           elementToAdd);



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form submitted!'),
          duration: Duration(milliseconds: 500),
        ),
      );
      Navigator.pop(context);

    }

  }


  @override
  void initState() {
    super.initState();

    if (widget.element != null) {
      _comment = widget.element!.commentaire;
      _status = widget.element!.statut;
      _images = widget.element!.elementPicture.cast<XFile>();
      _elementId = widget.element!.elementID;
      _elementName = widget.element!.elementName;
    } else{
      _elementId = Uuid().v4();
    }
  }

  @override
  Widget build(BuildContext context) {
  final bool isViewOnly = context.read<RapportProvider>().getPropertyByRoomId(widget.roomToAddTo!.roomId)?.statutRapport == EtatsRapport.termine;
    return Scaffold(
      appBar: AppBar(title: Text('Element Inspection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Comment (optional)'),
                initialValue: _comment,
                maxLines: 3,
                enabled: !isViewOnly,
                onSaved: isViewOnly ? null : (value) => _comment = value ?? '',
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<RoomElements>(
                decoration: InputDecoration(labelText: 'Room Element'),
                value: _elementName,
                items:
                    RoomElements.values.map((element) {
                      return DropdownMenuItem(
                        value: element,
                        child: Text(roomElementString( element)),
                      );
                    }).toList(),
                onChanged: isViewOnly ? null : (value) => setState(() => _elementName = value!),
                validator:
                    (value) => value == null ? 'Please select a room element' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<EtatsElement>(
                decoration: InputDecoration(labelText: 'Status'),
                value: _status,
                items:
                    EtatsElement.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(etatElementString(status)),
                      );
                    }).toList(),
                onChanged: isViewOnly ? null : (value) => setState(() => _status = value!),
                validator:
                    (value) => value == null ? 'Please select a status' : null,
              ),
              SizedBox(height: 16),
              Text('Pictures (up to 3):'),
              SizedBox(height: 8),
              Row(
                children: [
                  ..._images.asMap().entries.map((entry) {
                    int idx = entry.key;
                    XFile? img = entry.value;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          child: Image.file(File(img!.path), fit: BoxFit.cover),
                        ),
                        if (!isViewOnly)
                          GestureDetector(
                            onTap: () => _removeImage(idx),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  if (_images.length < 3 && !isViewOnly)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.grey[300],
                        onPressed: _selectImageSourceAndPick,
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24),
              if (!isViewOnly)
                ElevatedButton(onPressed: _submit, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
