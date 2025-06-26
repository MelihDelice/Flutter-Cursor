import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/game_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameProvider()),
        ChangeNotifierProvider(create: (context) => MultiplayerProvider()),
      ],
      child: MaterialApp(
        title: 'Quiz Oyunu',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Ubuntu',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Ubuntu'),
            displayMedium: TextStyle(fontFamily: 'Ubuntu'),
            displaySmall: TextStyle(fontFamily: 'Ubuntu'),
            headlineLarge: TextStyle(fontFamily: 'Ubuntu'),
            headlineMedium: TextStyle(fontFamily: 'Ubuntu'),
            headlineSmall: TextStyle(fontFamily: 'Ubuntu'),
            titleLarge: TextStyle(fontFamily: 'Ubuntu'),
            titleMedium: TextStyle(fontFamily: 'Ubuntu'),
            titleSmall: TextStyle(fontFamily: 'Ubuntu'),
            bodyLarge: TextStyle(fontFamily: 'Ubuntu'),
            bodyMedium: TextStyle(fontFamily: 'Ubuntu'),
            bodySmall: TextStyle(fontFamily: 'Ubuntu'),
            labelLarge: TextStyle(fontFamily: 'Ubuntu'),
            labelMedium: TextStyle(fontFamily: 'Ubuntu'),
            labelSmall: TextStyle(fontFamily: 'Ubuntu'),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
