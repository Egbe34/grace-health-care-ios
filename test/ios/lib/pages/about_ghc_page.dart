import 'package:flutter/material.dart';

class AboutGhcPage extends StatelessWidget {
  const AboutGhcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("About GHC"),
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _heroCard(),

          const SizedBox(height: 14),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Grace Health Care (GHC)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Grace Health Care is a healthcare platform created to improve access to trusted and responsible healthcare services in Cameroon. "
                      "Our goal is to help individuals and families make better health decisions by connecting them with licensed doctors, proper consultations, laboratory support, and follow-up care.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "GHC is built on the belief that good healthcare should not be a luxury. Everyone deserves the opportunity to manage their health properly, no matter their financial situation. "
                      "Being healthy is a form of wealth, and you do not have to be rich before you can start taking your health seriously.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Why GHC was created",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "As a Cameroonian based in Germany, I have seen how important proper healthcare systems, early diagnosis, and professional follow-up can be in protecting lives. "
                      "I also know that in many communities back home, some illnesses are still misunderstood, ignored, or even attributed to superstition, while the real issue may simply be poor health management, late diagnosis, or lack of access to the right medical guidance.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Grace Health Care was created to encourage a healthier culture: one where people do not wait until things become worse, do not rely on random drugs without diagnosis, and do not replace professional care with guesswork. "
                      "Instead, we encourage proper consultation, laboratory testing when necessary, prescribed medication, and responsible follow-up with qualified doctors.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "What GHC encourages",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 10),
                _Bullet(
                  text:
                  "Consult a licensed doctor when you do not feel well instead of starting treatment without diagnosis",
                ),
                _Bullet(
                  text:
                  "Carry out blood tests and other laboratory investigations when necessary to understand what is really wrong",
                ),
                _Bullet(
                  text:
                  "Avoid self-medication and buying random drugs from pharmacies or nearby stores without medical advice",
                ),
                _Bullet(
                  text:
                  "Use prescribed medication based on proper diagnosis and professional recommendation",
                ),
                _Bullet(
                  text:
                  "Follow up with healthcare professionals to monitor recovery and long-term health",
                ),
                _Bullet(
                  text:
                  "Take preventive care seriously, because your health is your life and one of your greatest forms of wealth",
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "What you can do with GHC",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 10),
                _Bullet(text: "Online medical consultations with licensed doctors"),
                _Bullet(text: "Home visit requests when available in your town"),
                _Bullet(text: "Laboratory test bookings"),
                _Bullet(text: "Pharmacy support and medication coordination"),
                _Bullet(text: "Cosmetic surgery consultations"),
                _Bullet(text: "Vaccination and chronic care support"),
                _Bullet(text: "Simple booking, follow-up, and support coordination"),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Our mission",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Our mission is to make healthcare more accessible, more trusted, and more responsible for individuals and families across Cameroon. "
                      "We want to help people move from fear, misinformation, and unhealthy habits toward informed choices, early diagnosis, and proper treatment.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    "assets/images/ceo.png",
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 82,
                        height: 82,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x1A1E5ED8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF1E5ED8),
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Founder",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Grace Health Care",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Built with a vision to bring trusted healthcare closer to every family in Cameroon and to encourage better health decisions through proper consultation, diagnosis, treatment, and follow-up.",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E5ED8),
            Color(0xFF0F4CC9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.favorite_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Health Matters",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Good health is a form of wealth. Grace Health Care exists to help people choose safer, smarter, and more responsible healthcare.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•  ",
            style: TextStyle(fontSize: 16, height: 1.3),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}