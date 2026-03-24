import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  bool _saving = false;

  // Reasonable starter prices (you can change later)
  final List<_Plan> plans = const [
    _Plan(
      id: "basic_monthly",
      name: "Basic Plan",
      badge: "Affordable",
      priceLabel: "4,000 FCFA / month",
      price: 4000,
      billingCycle: "monthly",
      features: [
        "1 consultation per month",
        "Discount on home visits",
        "Basic health monitoring",
      ],
    ),
    _Plan(
      id: "family_monthly",
      name: "Family Plan",
      badge: "Most Popular",
      priceLabel: "10,000 FCFA / month",
      price: 10000,
      billingCycle: "monthly",
      highlight: true,
      features: [
        "Up to 4 family members",
        "Priority booking",
        "Pediatrics & maternity access",
        "Discounted lab services",
      ],
    ),
    _Plan(
      id: "premium_monthly",
      name: "Premium Plan",
      badge: "Full Access",
      priceLabel: "20,000 FCFA / month",
      price: 20000,
      billingCycle: "monthly",
      features: [
        "Unlimited consultations",
        "1 home visit per month",
        "Medication discount",
        "Priority response 24/7",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
        title: const Text("Subscription Plans"),
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text(
              "Choose the plan that fits your needs.",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ...plans.map(
                  (p) => _PlanCard(
                plan: p,
                onTap: () => _openPlanForm(p),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "This will save your chosen plan in Firestore. Payments can be connected later.",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            if (_saving) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPlanForm(_Plan plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack("Please login first to select a plan.");
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: user.email ?? "");

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
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
                      "Confirm ${plan.name}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      plan.priceLabel,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w800,
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
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone (e.g. +237...)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter your phone number";
                        }
                        if (!v.trim().startsWith("+")) {
                          return "Use international format like +237...";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email (optional)",
                        border: OutlineInputBorder(),
                      ),
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
                    Navigator.pop(ctx);
                    await _saveSubscription(
                      plan: plan,
                      fullName: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                    );
                  },
                  child: const Text("Save Subscription"),
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
        );
      },
    );
  }

  Future<void> _saveSubscription({
    required _Plan plan,
    required String fullName,
    required String phone,
    required String email,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final now = FieldValue.serverTimestamp();

      /// ✅ 1) Save FULL subscription (easy for admin/customer service)
      final subRef =
      FirebaseFirestore.instance.collection("subscriptions").doc(user.uid);

      final subData = {
        "userId": user.uid,
        "fullName": fullName,
        "phone": phone,
        "email": email.isEmpty ? null : email,
        "planId": plan.id,
        "planName": plan.name,
        "price": plan.price,
        "priceLabel": plan.priceLabel,
        "currency": "XAF",
        "billingCycle": plan.billingCycle,
        "status": "pending", // later switch to active after payment
        "updatedAt": now,
        "createdAt": now,
      };

      await subRef.set(subData, SetOptions(merge: true));

      /// ✅ 2) Save QUICK subscription summary inside the user profile
      /// This makes it easy for the app to display "Active/Pending Plan" anywhere.
      final userRef =
      FirebaseFirestore.instance.collection("users").doc(user.uid);

      await userRef.set({
        "subscription": {
          "planId": plan.id,
          "planName": plan.name,
          "status": "pending",
          "price": plan.price,
          "currency": "XAF",
          "billingCycle": plan.billingCycle,
          "updatedAt": now,
        }
      }, SetOptions(merge: true));

      _showSnack("✅ ${plan.name} saved successfully!");
    } catch (e) {
      _showSnack("❌ Failed to save subscription: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _Plan {
  final String id;
  final String name;
  final String badge;
  final String priceLabel;
  final int price;
  final String billingCycle;
  final List<String> features;
  final bool highlight;

  const _Plan({
    required this.id,
    required this.name,
    required this.badge,
    required this.priceLabel,
    required this.price,
    required this.billingCycle,
    required this.features,
    this.highlight = false,
  });
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border =
    plan.highlight ? const Color(0xFF1E5ED8) : const Color(0xFFE2E8F0);
    final badgeBg =
    plan.highlight ? const Color(0x1A1E5ED8) : const Color(0xFFF1F5F9);
    final badgeText =
    plan.highlight ? const Color(0xFF1E5ED8) : const Color(0xFF475569);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: plan.highlight ? 1.5 : 1),
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
                    plan.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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
                    plan.badge,
                    style: TextStyle(
                      color: badgeText,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.priceLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            ...plan.features.map(
                  (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 18, color: Color(0xFF22C55E)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.highlight
                      ? const Color(0xFF1E5ED8)
                      : const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onTap,
                child: const Text("Choose Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}