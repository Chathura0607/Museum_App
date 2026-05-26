import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  static void setThemeMode(BuildContext context, ThemeMode newMode) {
    _MuseumAppState? state = context.findAncestorStateOfType<_MuseumAppState>();
    state?.setThemeMode(newMode);
  }

  @override
  State<MuseumApp> createState() => _MuseumAppState();
}

class _MuseumAppState extends State<MuseumApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtSphere Guide',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      supportedLocales: const [Locale('en'), Locale('si')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: const CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFC9A84C),
          primary: const Color(0xFFC9A84C),
          secondary: const Color(0xFF2C1810),
          surface: const Color(0xFF1A1A1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Color(0xFFC9A84C),
            letterSpacing: -1.5,
            height: 1.1,
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFFC9A84C),
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFFC9A84C),
            letterSpacing: 0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC9A84C),
            letterSpacing: 0.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 17,
            height: 1.6,
            color: Colors.white,
            letterSpacing: 0.1,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.white70,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Color(0xFFC9A84C),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFFC9A84C),
            letterSpacing: 3,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.white10, width: 1),
          ),
          color: const Color(0xFF1E1E1E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 12,
            shadowColor: Colors.black,
            backgroundColor: const Color(0xFFC9A84C),
            foregroundColor: const Color(0xFF2C1810),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: const CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1810),
          primary: const Color(0xFF2C1810),
          secondary: const Color(0xFFC9A84C),
          surface: const Color(0xFFFCFAF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCFAF7),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C1810),
            letterSpacing: -1.5,
            height: 1.1,
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C1810),
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C1810),
            letterSpacing: 0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C1810),
            letterSpacing: 0.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 17,
            height: 1.6,
            color: Colors.black87,
            letterSpacing: 0.1,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black54,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF2C1810),
          foregroundColor: Color(0xFFC9A84C),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFFC9A84C),
            letterSpacing: 3,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.brown.shade50, width: 1),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: const Color(0xFF2C1810).withOpacity(0.3),
            backgroundColor: const Color(0xFF2C1810),
            foregroundColor: const Color(0xFFC9A84C),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
