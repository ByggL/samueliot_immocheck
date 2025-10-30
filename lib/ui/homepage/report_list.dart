import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:samueliot_immocheck/ui/forms/build_rapport_form.dart';
import 'package:samueliot_immocheck/ui/homepage/report_card.dart';
import 'package:provider/provider.dart';

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  List<Rapport> _reports = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchField = 'name'; // current field used for filtering
  String _searchQuery = '';

  String _filterValue = 'none';

  // Filtered list based on query and field
  // List<Rapport> get _filteredReports {
  //   return _reports.where((report) {
  //     final fieldValue = switch (_searchField) {
  //       'name' => report.nom,
  //       'type' => report.propertyType.toString(),
  //       'date' => DateFormat('yyyy-MM-dd – kk:mm').format(report.creationDate),
  //       _ => report.nom,
  //     };

  //     final isIncludedByFilter = switch (_filterValue) {
  //       'none' => true,
  //       'inprogress' => report.statutRapport == EtatsRapport.enCours,
  //       'finished' => report.statutRapport == EtatsRapport.termine,
  //       _ => true,
  //     };

  //     if (_searchField.isEmpty) return isIncludedByFilter;

  //     return fieldValue.toLowerCase().contains(_searchQuery.toLowerCase()) &&
  //         isIncludedByFilter;
  //   }).toList();
  // }

  List<Rapport> get _filteredReports {
    Iterable<Rapport> filtered = _reports;

    filtered = filtered.where((report) {
      final isIncludedByFilter = switch (_filterValue) {
        'none' => true,
        'inprogress' => report.statutRapport == EtatsRapport.enCours,
        'finished' => report.statutRapport == EtatsRapport.termine,
        _ => true,
      };

      return isIncludedByFilter;
    });

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        final fieldValue = switch (_searchField) {
          'name' => report.nom,
          'type' => report.propertyType.toString(),
          'date' => DateFormat(
            'yyyy-MM-dd – kk:mm',
          ).format(report.creationDate),
          _ => report.nom,
        };
        return fieldValue.toLowerCase().contains(_searchQuery.toLowerCase());
      });
    }

    return filtered.toList();
  }

  @override
  void initState() {
    super.initState();
    context.read<RapportProvider>().loadRapports();
  }

  @override
  Widget build(BuildContext context) {
    _reports = context.watch<RapportProvider>().properties.cast<Rapport>();
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

          DropdownButton<String>(
            value: _filterValue,
            onChanged: (value) {
              setState(() {
                _filterValue = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: 'none', child: Text('None')),
              DropdownMenuItem(value: 'inprogress', child: Text('En cours')),
              DropdownMenuItem(value: 'finished', child: Text('Terminé')),
            ],
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
                          onDelete: () {
                            context.read<RapportProvider>().removeRapport(
                              report,
                            );
                            setState(() {});
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, BuildRapportForm.route());
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
