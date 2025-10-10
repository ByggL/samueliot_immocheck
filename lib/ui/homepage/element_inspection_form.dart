import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'dart:io';
import 'package:samueliot_immocheck/providers/element_provider.dart';

class ElementInspectionFormPage extends StatefulWidget {
  final RoomElement? element;
  const ElementInspectionFormPage({super.key,this.element});

    static Route<void> route(RoomElement? element) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/elementsInspectionForm'),
      builder: (_) => ElementInspectionFormPage(element:element),
    );
  }

  @override
  State<ElementInspectionFormPage> createState() => _ElementInspectionFormPageState();
}

class _ElementInspectionFormPageState extends State<ElementInspectionFormPage> {

  final _formKey = GlobalKey<FormState>();


  String _comment = '';
  EtatsElement? _status;
  List<XFile> _images = [];



  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 3) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }


  void _submit() {
    //TODO: add logic after validation
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted!'),duration: Duration(milliseconds: 500),),
      );
    }
  }

  @override 
  void initState() {
    super.initState();
    if (widget.element != null) {
      _comment = widget.element!.commentaire;
      _status = widget.element!.statut;
      _images = widget.element!.elementPicture.cast<XFile>();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onSaved: (value) => _comment = value ?? '',
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<EtatsElement>(
                decoration: InputDecoration(labelText: 'Status'),
                initialValue: _status,
                items: EtatsElement.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value),
                validator: (value) => value == null ? 'Please select a status' : null,
              ),
              SizedBox(height: 16),
              Text('Pictures (up to 3):'),
              SizedBox(height: 8),
              Row(
                children: [
                  ..._images.asMap().entries.map((entry) {
                    int idx = entry.key;
                    XFile img = entry.value;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          child: Image.file(
                            File(img.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeImage(idx),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (_images.length < 3)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, color: Colors.black87),
                        onPressed: () async {
                          final ImageSource? source = await showDialog<ImageSource>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Select Image Source'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                                    child: const Text('Camera'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, ImageSource.gallery),
                                    child: const Text('Gallery'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (source != null) {
                            _pickImage(source);
                          }
                        },
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}