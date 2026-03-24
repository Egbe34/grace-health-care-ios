import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Doctor Dashboard (Admin only)
/// Collection: doctors
/// Fields used:
/// - name (string)
/// - specialty (string)
/// - city (string)
/// - hospital (string)
/// - available (bool)
/// - type (string) -> local / online
/// - createdAt (timestamp)
/// - updatedAt (timestamp)
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  String _search = "";

  bool _isAdminEmail(String? email) {
    final e = (email ?? '').toLowerCase().trim();
    return e == "ekema1234@gmail.com" || e == "egbe1234@gmail.com";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = _isAdminEmail(user?.email);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1E5ED8),
          foregroundColor: Colors.white,
          title: const Text("Doctor Dashboard"),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Access denied. Admin only.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
        title: const Text("Doctor Dashboard"),
        actions: [
          IconButton(
            tooltip: "Add Doctor",
            onPressed: () => _openDoctorForm(),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("doctors")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ErrorBox(message: snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const _EmptyState();
                }

                final filtered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;

                  final doctorName = (
                      data["name"] ??
                          data["fullName"] ??
                          ""
                  ).toString().toLowerCase();

                  final specialty =
                  (data["specialty"] ?? "").toString().toLowerCase();

                  final city = (data["city"] ?? "").toString().toLowerCase();

                  final q = _search.trim().toLowerCase();
                  if (q.isEmpty) return true;

                  return doctorName.contains(q) ||
                      specialty.contains(q) ||
                      city.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No doctors match your search."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final doctorName = (
                        data["name"] ??
                            data["fullName"] ??
                            "Doctor"
                    ).toString();

                    final specialty = (data["specialty"] ?? "-").toString();
                    final city = (data["city"] ?? "-").toString();
                    final hospital = (data["hospital"] ?? "").toString();
                    final type = (data["type"] ?? "local").toString();
                    final available = (data["available"] ?? false) == true;

                    return _DoctorCard(
                      doctorId: doc.id,
                      fullName: doctorName,
                      specialty: specialty,
                      city: city,
                      hospital: hospital,
                      type: type,
                      available: available,
                      onToggle: (val) => _setAvailability(doc.id, val),
                      onEdit: () => _openDoctorForm(
                        doctorId: doc.id,
                        existing: data,
                      ),
                      onDelete: () => _confirmDelete(doc.id, doctorName),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search doctor name, specialty, city...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniStatChip(
                  icon: Icons.check_circle_outline,
                  label: "ACTIVE = available true",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStatChip(
                  icon: Icons.cancel_outlined,
                  label: "INACTIVE = available false",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E5ED8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setAvailability(String doctorId, bool available) async {
    try {
      await FirebaseFirestore.instance.collection("doctors").doc(doctorId).set(
        {
          "available": available,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(available ? "✅ Marked ACTIVE" : "✅ Marked INACTIVE")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update: $e")),
      );
    }
  }

  Future<void> _confirmDelete(String doctorId, String fullName) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Doctor"),
        content: Text("Delete $fullName? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await FirebaseFirestore.instance.collection("doctors").doc(doctorId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Deleted")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Delete failed: $e")),
      );
    }
  }

  Future<void> _openDoctorForm({
    String? doctorId,
    Map<String, dynamic>? existing,
  }) async {
    final isEdit = doctorId != null;

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(
      text: (existing?["name"] ?? existing?["fullName"] ?? "").toString(),
    );
    final specialtyCtrl =
    TextEditingController(text: (existing?["specialty"] ?? "").toString());
    final cityCtrl =
    TextEditingController(text: (existing?["city"] ?? "").toString());
    final hospitalCtrl =
    TextEditingController(text: (existing?["hospital"] ?? "").toString());
    final typeCtrl =
    TextEditingController(text: (existing?["type"] ?? "local").toString());

    bool available = (existing?["available"] ?? true) == true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? "Edit Doctor" : "Add Doctor",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: available
                                ? const Color(0x1A22C55E)
                                : const Color(0x1AEF4444),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            available ? "ACTIVE" : "INACTIVE",
                            style: TextStyle(
                              color: available
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFEF4444),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: "Doctor Name",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? "Required" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: specialtyCtrl,
                            decoration: const InputDecoration(
                              labelText: "Specialty",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? "Required" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(
                              labelText: "City / Country",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? "Required" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: hospitalCtrl,
                            decoration: const InputDecoration(
                              labelText: "Hospital / Clinic (optional)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: typeCtrl.text.isEmpty ? "local" : typeCtrl.text,
                            decoration: const InputDecoration(
                              labelText: "Doctor Type",
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "local",
                                child: Text("Local"),
                              ),
                              DropdownMenuItem(
                                value: "online",
                                child: Text("Online"),
                              ),
                            ],
                            onChanged: (v) {
                              typeCtrl.text = v ?? "local";
                            },
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Active (Available)"),
                            subtitle: const Text("Turn OFF to mark doctor as inactive"),
                            value: available,
                            onChanged: (v) {
                              setModalState(() {
                                available = v;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E5ED8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final doctorName = nameCtrl.text.trim();

                          final payload = {
                            "name": doctorName,
                            "fullName": doctorName, // keep for old screens
                            "specialty": specialtyCtrl.text.trim(),
                            "city": cityCtrl.text.trim(),
                            "hospital": hospitalCtrl.text.trim(),
                            "type": typeCtrl.text.trim().isEmpty
                                ? "local"
                                : typeCtrl.text.trim(),
                            "available": available,
                            "updatedAt": FieldValue.serverTimestamp(),
                            if (!isEdit) "createdAt": FieldValue.serverTimestamp(),
                          };

                          try {
                            if (isEdit) {
                              await FirebaseFirestore.instance
                                  .collection("doctors")
                                  .doc(doctorId)
                                  .set(payload, SetOptions(merge: true));
                            } else {
                              await FirebaseFirestore.instance
                                  .collection("doctors")
                                  .add(payload);
                            }

                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? "✅ Updated" : "✅ Added"),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("❌ Save failed: $e")),
                            );
                          }
                        },
                        child: Text(isEdit ? "Save Changes" : "Add Doctor"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String doctorId;
  final String fullName;
  final String specialty;
  final String city;
  final String hospital;
  final String type;
  final bool available;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DoctorCard({
    required this.doctorId,
    required this.fullName,
    required this.specialty,
    required this.city,
    required this.hospital,
    required this.type,
    required this.available,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final badgeBg =
    available ? const Color(0x1A22C55E) : const Color(0x1AEF4444);
    final badgeText =
    available ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  available ? "ACTIVE" : "INACTIVE",
                  style: TextStyle(
                    color: badgeText,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            specialty,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  city,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (hospital.trim().isNotEmpty && hospital.trim() != "-") ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hospital,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Text(
            "Type: ${type.isEmpty ? 'local' : type}",
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Availability",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  subtitle: Text(available ? "Active" : "Inactive"),
                  value: available,
                  onChanged: onToggle,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: "Edit",
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: "Delete",
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "No doctors found.\nTap + to add doctors.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}