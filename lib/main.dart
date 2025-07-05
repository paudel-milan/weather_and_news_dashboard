// lib/main.dart 

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:weather_and_news_app/core/theme/app_theme.dart';
import 'package:weather_and_news_app/controllers/weather_provider.dart';
import 'package:weather_and_news_app/controllers/news_provider.dart';
import 'package:weather_and_news_app/controllers/theme_provider.dart'; // IMPORT THEME PROVIDER
import 'package:weather_and_news_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }


  await Hive.initFlutter();
  await Hive.openBox('newsBox');
  await Hive.openBox('weatherCitiesBox');
  await Hive.openBox(ThemeProvider.themeBoxName); // OPEN THE THEME SETTINGS BOX

  await _requestLocationPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // ADD THEME PROVIDER HERE
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _requestLocationPermission() async {
  
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('Location services are disabled.');
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('Location permissions are denied.');
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint(
        'Location permissions are permanently denied, we cannot request permissions.');
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  debugPrint('Location permissions granted.');
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>( // WRAP WITH CONSUMER TO LISTEN TO THEME CHANGES
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Weather & News Dashboard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode, // USE THEMEPROVIDER'S CURRENT THEME MODE
          home: const HomeScreen(),
        );
      },
    );
  }
}