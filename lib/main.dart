import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GHCApp());
}

class GHCApp extends StatefulWidget {
  const GHCApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_GHCAppState>();
    state?.setLocale(locale);
  }

  @override
  State<GHCApp> createState() => _GHCAppState();
}

class _GHCAppState extends State<GHCApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grace Health Care',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'App Loaded Successfully',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}