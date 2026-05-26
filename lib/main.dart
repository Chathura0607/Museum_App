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
    // Firebase already initialized
  }
  runApp(const MuseumApp());
}

class MuseumApp extends StatefulWidget {
  const MuseumApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MuseumAppState? state =
        context.findAncestorStateOfType<_MuseumAppState>();
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
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1810),
          primary: const Color(0xFF2C1810),
          secondary: const Color(0xFFC9A84C),
          surface: const Color(0xFFFAF7F2),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C1810),
          foregroundColor: Color(0xFFC9A84C),
          titleTextStyle: TextStyle(
            color: Color(0xFFC9A84C),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFFC9A84C)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C1810),
          selectedItemColor: Color(0xFFC9A84C),
          unselectedItemColor: Colors.white54,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A84C),
            foregroundColor: const Color(0xFF1C1208),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2C1810),
          foregroundColor: Color(0xFFC9A84C),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
