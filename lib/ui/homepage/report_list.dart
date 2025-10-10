import 'package:flutter/material.dart';
import 'report_card.dart'; // make sure this path matches your structure

// PLACEHOLDER CLASS FOR UI
class Report {
  final String name;
  final String type;
  final String date;
  final String address;
  final String status;

  Report({
    required this.name,
    required this.type,
    required this.date,
    required this.address,
    required this.status,
  });
}

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  // Placeholder list of reports
  final List<Report> _reports = [
    Report(
      name: "Engine Inspection",
      type: "Maintenance Report",
      date: "2025-10-08",
      address: "1234 Elm Street, Los Angeles, CA",
      status: "Finished",
    ),
    Report(
      name: "Emission Check",
      type: "Environmental Report",
      date: "2025-09-20",
      address: "456 Oak Avenue, San Francisco, CA",
      status: "In Progress",
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchField = 'name'; // current field used for filtering
  String _searchQuery = '';

  // Filtered list based on query and field
  List<Report> get _filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    return _reports.where((report) {
      final fieldValue = switch (_searchField) {
        'name' => report.name,
        'type' => report.type,
        'date' => report.date,
        _ => report.name,
      };
      return fieldValue.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addReport(Report report) {
    setState(() {
      _reports.add(report);
    });
  }

  void _removeReport(Report report) {
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
                          name: report.name,
                          type: report.type,
                          date: report.date,
                          address: report.address,
                          status: report.status,
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
            Report(
              name: "New Vehicle Check",
              type: "Safety Report",
              date: DateTime.now().toString().split(' ')[0],
              address: "789 Pine Street, Seattle, WA",
              status: "Pending",
            ),
          );
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
