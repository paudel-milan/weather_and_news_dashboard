// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import NewsProvider
import 'package:weather_and_news_app/controllers/weather_provider.dart'; // Import WeatherProvider

// Placeholder screens - we'll create these next
import 'package:weather_and_news_app/screens/weather_screen.dart';
import 'package:weather_and_news_app/screens/news_screen.dart';
import 'package:weather_and_news_app/screens/bookmarks_screen.dart'; // For news bookmarks

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Index for the selected tab

  // List of widgets (screens) to display for each tab
  static final List<Widget> _widgetOptions = <Widget>[
    const WeatherScreen(),
    const NewsScreen(),
    const BookmarksScreen(), // Assuming a dedicated screen for news bookmarks
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fetch initial data when the HomeScreen initializes
    // This ensures data is ready when the respective tab is first viewed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeatherForCurrentLocation();
      // NewsProvider fetches initial headlines in its constructor, so no need to call it here unless you want to refresh
      // Provider.of<NewsProvider>(context, listen: false).fetchTopHeadlines();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Using IndexedStack to preserve the state of the screens
        // when switching between tabs
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks', // For news bookmarks
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}