import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  String _search = "";
  String? _selectedCity;
  String? _selectedSpecialty;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
        title: const Text("Find a Doctor"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('available', isEqualTo: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];

          final cityValues = docs
              .map((d) => (d.data()['city'] ?? '').toString().trim())
              .where((v) => v.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final specialtyValues = docs
              .map((d) => (d.data()['specialty'] ?? '').toString().trim())
              .where((v) => v.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filtered = docs.where((doc) {
            final data = doc.data();

            final doctorName = (
                data['name'] ??
                    data['fullName'] ??
                    ''
            ).toString().toLowerCase();

            final city = (data['city'] ?? '').toString();
            final specialty = (data['specialty'] ?? '').toString();

            final matchesSearch =
                _search.isEmpty || doctorName.contains(_search.toLowerCase());

            final matchesCity =
                _selectedCity == null ||
                    _selectedCity!.isEmpty ||
                    city == _selectedCity;

            final matchesSpecialty =
                _selectedSpecialty == null ||
                    _selectedSpecialty!.isEmpty ||
                    specialty == _selectedSpecialty;

            return matchesSearch && matchesCity && matchesSpecialty;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Search doctor name...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _search = v.trim();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _simpleDropdown(
                            hint: "City",
                            value: _selectedCity,
                            items: cityValues,
                            onChanged: (v) {
                              setState(() {
                                _selectedCity = v;
                              });
                            },
                            onClear: () {
                              setState(() {
                                _selectedCity = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _simpleDropdown(
                            hint: "Specialty",
                            value: _selectedSpecialty,
                            items: specialtyValues,
                            onChanged: (v) {
                              setState(() {
                                _selectedSpecialty = v;
                              });
                            },
                            onClear: () {
                              setState(() {
                                _selectedSpecialty = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                  child: Text("No available doctors found."),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data();

                    final doctorName = (
                        data['name'] ??
                            data['fullName'] ??
                            'Doctor'
                    ).toString();

                    final specialty =
                    (data['specialty'] ?? '').toString();

                    final city = (data['city'] ?? '').toString();

                    final hospital =
                    (data['hospital'] ?? '').toString();

                    final type = (data['type'] ?? 'local').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                            color: Colors.black.withOpacity(0.06),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        title: Text(
                          doctorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (specialty.isNotEmpty) Text(specialty),
                            if (city.isNotEmpty) Text("📍 $city"),
                            if (hospital.isNotEmpty) Text("🏥 $hospital"),
                            Text(
                              type == "online"
                                  ? "🌍 Online Only"
                                  : "✅ Local Doctor",
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5ED8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, {
                              "doctorId": doc.id,
                              "fullName": doctorName,
                              "name": doctorName,
                              "specialty": specialty,
                              "city": city,
                              "hospital": hospital,
                              "type": type,
                            });
                          },
                          child: const Text("Select"),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _simpleDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(hint),
                items: items
                    .map(
                      (v) => DropdownMenuItem<String>(
                    value: v,
                    child: Text(v),
                  ),
                )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (value != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}