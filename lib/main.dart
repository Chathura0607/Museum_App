import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MuseumApp());
}

class MuseumApp extends StatefulWidget {
  const MuseumApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MuseumAppState? state = context.findAncestorStateOfType<_MuseumAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MuseumApp> createState() => _MuseumAppState();
}

class _MuseumAppState extends State<MuseumApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtSphere Guide',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('si')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1810),
          primary: const Color(0xFF2C1810),
          secondary: const Color(0xFFC9A84C),
          surface: const Color(0xFFFCFAF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCFAF7),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C1810), letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF2C1810)),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: Colors.black54),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF2C1810),
          foregroundColor: Color(0xFFC9A84C),
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC9A84C)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.brown.shade100, width: 1),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF2C1810),
            foregroundColor: const Color(0xFFC9A84C),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
