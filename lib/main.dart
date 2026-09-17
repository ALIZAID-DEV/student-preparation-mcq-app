import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/name_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'services/ad_service.dart';

const FirebaseOptions webOptions = FirebaseOptions(
  apiKey: "AIzaSyA56p-VQiFtNLvRlnwcMo3WNRNmxz4eD14",
  authDomain: "student-preparation.firebaseapp.com",
  databaseURL: "https://student-preparation-default-rtdb.firebaseio.com",
  projectId: "student-preparation",
  storageBucket: "student-preparation.firebasestorage.app",
  messagingSenderId: "46780603577",
  appId: "1:46780603577:web:7b3c58a03aa13de1d2cf68",
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: webOptions);
    } else {
      await Firebase.initializeApp();
    }
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
  }

  try {
    await FirebaseAuth.instance.signInAnonymously();
    debugPrint('✅ Anonymous login successful');
  } catch (e) {
    debugPrint('❌ Firebase Auth Error: $e');
  }

  if (!kIsWeb) {
    try {
      await AdService.initAds();
    } catch (e) {
      debugPrint('AdMob init skipped: $e');
    }
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Student Preparation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const NameScreen(),
    );
  }
}
