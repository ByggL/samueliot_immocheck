import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'report_card.dart'; // make sure this path matches your structure

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  // Placeholder list of reports
  final List<Rapport> _reports = [
    Rapport(
      nom: "Appartement",
      propertyType: PropertyTypes.appartement,
      creationDate: DateTime(2025, 10, 8),
      adresse: "1234 Elm Street, Los Angeles, CA",
      statutRapport: EtatsRapport.termine,
      roomList: [
        Room(
          roomName: "Pièce de vie",
          statut: EtatsElement.ok,
          elements: [
            RoomElement(
              commentaire: "RAS",
              statut: EtatsElement.ok,
              elementPicture: ["elementPicture"],
            ),
          ],
        ),
      ],
      signature: "oui",
    ),
    Rapport(
      nom: "Maison",
      propertyType: PropertyTypes.maison,
      creationDate: DateTime(2025, 9, 20),
      adresse: "1234 Elm Street, Los Angeles, CA",
      statutRapport: EtatsRapport.enCours,
      roomList: [
        Room(
          roomName: "Pièce de vie",
          statut: EtatsElement.ok,
          elements: [
            RoomElement(
              commentaire: "RAS",
              statut: EtatsElement.ok,
              elementPicture: ["elementPicture"],
            ),
          ],
        ),
      ],
      signature: "oui",
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchField = 'name'; // current field used for filtering
  String _searchQuery = '';

  // Filtered list based on query and field
  List<Rapport> get _filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    return _reports.where((report) {
      final fieldValue = switch (_searchField) {
        'name' => report.nom,
        'type' => report.propertyType.toString(),
        'date' => DateFormat('yyyy-MM-dd – kk:mm').format(report.creationDate),
        _ => report.nom,
      };
      return fieldValue.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addReport(Rapport report) {
    setState(() {
      _reports.add(report);
    });
  }

  void _removeReport(Rapport report) {
    setState(() {
      _reports.remove(report);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          // 🔍 Search bar + dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _searchField,
                  onChanged: (value) {
                    setState(() {
                      _searchField = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'type', child: Text('Type')),
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                  ],
                ),
              ],
            ),
          ),

          // 📋 Report list
          Expanded(
            child:
                _filteredReports.isEmpty
                    ? const Center(
                      child: Text(
                        "No matching reports.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = _filteredReports[index];
                        return ReportCard(
                          report: report,
                          onDelete: () => _removeReport(report),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // PLACEHOLDER dummy report add button
          _addReport(
            Rapport(
              nom: "Appartement",
              propertyType: PropertyTypes.appartement,
              creationDate: DateTime(2025, 10, 8),
              adresse: "1234 Elm Street, Los Angeles, CA",
              statutRapport: EtatsRapport.termine,
              roomList: [
                Room(
                  roomName: "Pièce de vie",
                  statut: EtatsElement.ok,
                  elements: [
                    RoomElement(
                      commentaire: "RAS",
                      statut: EtatsElement.ok,
                      elementPicture: ["elementPicture"],
                    ),
                  ],
                ),
              ],
              signature: "oui",
            ),
          );
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
