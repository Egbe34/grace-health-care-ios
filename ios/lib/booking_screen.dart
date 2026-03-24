import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ghc_constants.dart';

class BookingScreen extends StatefulWidget {
  final String? prefillServiceId;

  const BookingScreen({super.key, this.prefillServiceId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _selectedServiceId;
  String _selectedServiceName = '';
  String _selectedServiceCategory = '';
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _noteCtrl = TextEditingController();

  bool _loadingPrefill = false;
  bool _saving = false;

  final List<String> _timeSlots = const [
    "08:00",
    "08:30",
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
  ];

  bool get _isFrench => Localizations.localeOf(context).languageCode == "fr";

  String get _bookAppointmentText =>
      _isFrench ? "Prendre rendez-vous" : "Book Appointment";
  String get _serviceText => _isFrench ? "Service" : "Service";
  String get _appointmentDateText =>
      _isFrench ? "Date du rendez-vous" : "Appointment Date";
  String get _timeSlotText => _isFrench ? "Créneau horaire" : "Time Slot";
  String get _noteOptionalText =>
      _isFrench ? "Note (optionnelle)" : "Note (optional)";
  String get _describeSymptomsText => _isFrench
      ? "Décrivez les symptômes ou la demande..."
      : "Describe symptoms or request...";
  String get _savingText => _isFrench ? "Enregistrement..." : "Saving...";
  String get _confirmBookingText =>
      _isFrench ? "Confirmer le rendez-vous" : "Confirm Booking";
  String get _tapToSelectDateText =>
      _isFrench ? "Touchez pour choisir une date" : "Tap to select date";
  String get _selectServiceText =>
      _isFrench ? "Sélectionnez un service" : "Select a service";
  String get _selectedServiceText =>
      _isFrench ? "Service sélectionné" : "Selected Service";
  String get _changeServiceText =>
      _isFrench ? "Changer le service" : "Change service";
  String get _consultationText =>
      _isFrench ? "consultation" : "consultation";
  String get _activeText => _isFrench ? "Actif" : "Active";

  @override
  void initState() {
    super.initState();
    if (widget.prefillServiceId != null && widget.prefillServiceId!.isNotEmpty) {
      _prefillService(widget.prefillServiceId!);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _prefillService(String serviceId) async {
    setState(() => _loadingPrefill = true);
    try {
      final doc =
      await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _selectedServiceId = doc.id;
          _selectedServiceName = (data['name'] ?? '').toString();
          _selectedServiceCategory = (data['category'] ?? '').toString();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingPrefill = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: GHC.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _saveBooking() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnack(_isFrench ? "Vous n'êtes pas connecté." : "You are not logged in.");
      return;
    }

    if (_selectedServiceId == null || _selectedServiceId!.isEmpty) {
      _showSnack(
          _isFrench ? "Veuillez sélectionner un service." : "Please select a service.");
      return;
    }
    if (_selectedDate == null) {
      _showSnack(_isFrench
          ? "Veuillez choisir une date de rendez-vous."
          : "Please pick an appointment date.");
      return;
    }
    if (_selectedTime == null || _selectedTime!.isEmpty) {
      _showSnack(
          _isFrench ? "Veuillez choisir un créneau horaire." : "Please pick a time slot.");
      return;
    }

    setState(() => _saving = true);

    try {
      final serviceId = _selectedServiceId!;
      final appointmentDate = Timestamp.fromDate(_dateOnly(_selectedDate!));
      final appointmentTime = _selectedTime!;

      final existing = await FirebaseFirestore.instance
          .collection('bookings')
          .where('serviceId', isEqualTo: serviceId)
          .where('appointmentDate', isEqualTo: appointmentDate)
          .where('appointmentTime', isEqualTo: appointmentTime)
          .where('status', whereIn: ['pending', 'confirmed'])
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;
        _showSnack(_isFrench
            ? "Ce créneau est déjà réservé. Veuillez en choisir un autre."
            : "This time slot is already booked. Please choose another.");
        return;
      }

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'email': user.email ?? '',
        'serviceId': serviceId,
        'serviceName': _selectedServiceName,
        'bookingType':
        _selectedServiceCategory.isEmpty ? 'consultation' : _selectedServiceCategory,
        'doctorId': null,
        'doctorName': null,
        'appointmentDate': appointmentDate,
        'appointmentTime': appointmentTime,
        'scheduled': true,
        'status': 'pending',
        'paymentStatus': 'unpaid',
        'paymentMethod': 'none',
        'note': _noteCtrl.text.trim(),
        'address': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSnack(_isFrench ? "Rendez-vous créé ✅" : "Booking created ✅");
      Navigator.pop(context);
    } catch (e) {
      _showSnack(_isFrench
          ? "Échec de création du rendez-vous : $e"
          : "Failed to create booking: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return "$dd/$mm/${d.year}";
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains("tele")) return Icons.video_call;
    if (c.contains("home")) return Icons.home;
    if (c.contains("lab")) return Icons.science;
    if (c.contains("cosmetic")) return Icons.health_and_safety;
    if (c.contains("consult")) return Icons.medical_services;
    if (c.contains("pharmacy")) return Icons.local_pharmacy;
    return Icons.local_hospital;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: GHC.primary,
        elevation: 0,
        title: Text(
          _bookAppointmentText,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loadingPrefill
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        children: [
          _CardShell(
            title: _serviceText,
            child: _ServicePicker(
              selectedServiceId: _selectedServiceId,
              selectedServiceName: _selectedServiceName,
              selectedCategory: _selectedServiceCategory,
              iconForCategory: _iconForCategory,
              onSelected: (id, name, category) {
                setState(() {
                  _selectedServiceId = id.isEmpty ? null : id;
                  _selectedServiceName = name;
                  _selectedServiceCategory = category;
                });
              },
              isFrench: _isFrench,
            ),
          ),
          const SizedBox(height: 12),
          _CardShell(
            title: _appointmentDateText,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: GHC.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_month, color: GHC.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? _tapToSelectDateText
                            : _formatDate(_selectedDate!),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CardShell(
            title: _timeSlotText,
            child: _TimeSlotsGrid(
              slots: _timeSlots,
              selected: _selectedTime,
              onSelect: (t) => setState(() => _selectedTime = t),
            ),
          ),
          const SizedBox(height: 12),
          _CardShell(
            title: _noteOptionalText,
            child: TextField(
              controller: _noteCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: _describeSymptomsText,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: GHC.primary, width: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GHC.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _saving ? null : _saveBooking,
              icon: _saving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.check_circle),
              label: Text(_saving ? _savingText : _confirmBookingText),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ServicePicker extends StatelessWidget {
  final String? selectedServiceId;
  final String selectedServiceName;
  final String selectedCategory;
  final bool isFrench;

  final IconData Function(String category) iconForCategory;
  final void Function(String id, String name, String category) onSelected;

  const _ServicePicker({
    required this.selectedServiceId,
    required this.selectedServiceName,
    required this.selectedCategory,
    required this.iconForCategory,
    required this.onSelected,
    required this.isFrench,
  });

  String get _failedToLoadServicesText =>
      isFrench ? "Impossible de charger les services :" : "Failed to load services:";
  String get _noActiveServicesText => isFrench
      ? "Aucun service actif trouvé dans Firestore."
      : "No active services found in Firestore.";
  String get _selectedServiceText =>
      isFrench ? "Service sélectionné" : "Selected Service";
  String get _consultationText =>
      isFrench ? "consultation" : "consultation";
  String get _changeServiceText =>
      isFrench ? "Changer le service" : "Change service";
  String get _selectServiceText =>
      isFrench ? "Sélectionnez un service" : "Select a service";

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return _ErrorBox(message: "$_failedToLoadServicesText ${snap.error}");
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(18),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _ErrorBox(message: _noActiveServicesText);
        }

        if (selectedServiceId != null && selectedServiceId!.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: GHC.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconForCategory(selectedCategory), color: GHC.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedServiceName.isEmpty
                            ? _selectedServiceText
                            : selectedServiceName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedCategory.isEmpty ? _consultationText : selectedCategory,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.swap_horiz),
                  onSelected: (_) {
                    onSelected("", "", "");
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: "change",
                      child: Text(_changeServiceText),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (selectedServiceId != null && selectedServiceId!.isNotEmpty)
                  ? selectedServiceId
                  : null,
              hint: Text(_selectServiceText),
              isExpanded: true,
              items: docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                final name = (data['name'] ?? 'Service').toString();
                final category = (data['category'] ?? 'consultation').toString();

                return DropdownMenuItem<String>(
                  value: d.id,
                  child: Row(
                    children: [
                      Icon(iconForCategory(category), color: GHC.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                final doc = docs.firstWhere((e) => e.id == id);
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? 'Service').toString();
                final category = (data['category'] ?? 'consultation').toString();
                onSelected(id, name, category);
              },
            ),
          ),
        );
      },
    );
  }
}

class _TimeSlotsGrid extends StatelessWidget {
  final List<String> slots;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _TimeSlotsGrid({
    required this.slots,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, i) {
        final t = slots[i];
        final isSelected = t == selected;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelect(t),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? GHC.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.black12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.12 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              t,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Text(message),
    );
  }
}