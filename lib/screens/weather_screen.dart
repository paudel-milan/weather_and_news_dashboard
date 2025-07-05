// lib/screens/weather_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_and_news_app/controllers/weather_provider.dart';
import 'package:weather_and_news_app/models/forecast_model.dart';
// For date formatting

// Custom Widgets
import 'package:weather_and_news_app/widgets/current_weather_card.dart';
import 'package:weather_and_news_app/widgets/hourly_forecast_list.dart';
import 'package:weather_and_news_app/widgets/daily_forecast_list.dart';
import 'package:weather_and_news_app/widgets/city_comparison_list.dart';
import 'package:weather_and_news_app/widgets/search_input_field.dart';
import 'package:weather_and_news_app/controllers/theme_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _citySearchController = TextEditingController();

  @override
  void dispose() {
    _citySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading &&
              weatherProvider.currentWeather == null &&
              weatherProvider.hourlyForecast == null &&
              weatherProvider.dailyForecast == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherProvider.errorMessage != null &&
              weatherProvider.currentWeather == null) {
            return RefreshIndicator(
              onRefresh: weatherProvider.refreshWeatherData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        weatherProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: weatherProvider.fetchWeatherForCurrentLocation,
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 20),
                    _buildCitySearchSection(context, weatherProvider),
                  ],
                ),
              ),
            );
          }

          // Main content when data is available or being refreshed
          return RefreshIndicator(
            onRefresh: weatherProvider.refreshWeatherData,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Essential for pull-to-refresh
              child: Column(
                // Removed the Padding directly around this Column
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add padding to individual sections or use a top/bottom SizedBox
                  const SizedBox(height: 16), // Padding from top of screen
                  // --- Current Weather ---
                  Padding(
                    // Apply padding to individual card
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CurrentWeatherCard(
                      weather: weatherProvider.currentWeather,
                      isLoading: weatherProvider.isLoading,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Hourly Forecast ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Hourly Forecast',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // HourlyForecastList already handles its own internal horizontal padding
                  HourlyForecastList(
                    forecasts: weatherProvider.hourlyForecast,
                    isLoading: weatherProvider.isLoading,
                  ),
                  const SizedBox(height: 20),

                  // --- Daily Forecast ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '7-Day Forecast',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    // Apply padding to daily list
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DailyForecastList(
                      forecasts: weatherProvider.dailyForecast
                          ?.whereType<DailyForecast>()
                          .toList(),
                      isLoading: weatherProvider.isLoading,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- City Search for Comparison ---
                  Padding(
                    // Apply padding to search section
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildCitySearchSection(context, weatherProvider),
                  ),
                  const SizedBox(height: 20),

                  // --- Saved Cities Comparison ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Saved Cities',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    // Apply padding to saved cities list
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CityComparisonList(
                      citiesWeather: weatherProvider.savedCitiesWeather,
                      onRemove: weatherProvider.removeCityFromComparison,
                    ),
                  ),
                  const SizedBox(height: 16), // Padding at bottom of screen
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCitySearchSection(
      BuildContext context, WeatherProvider weatherProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search City',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        SearchInputField(
          controller: _citySearchController,
          hintText: 'Enter city name (e.g., London)',
          onSubmitted: (cityName) {
            if (cityName.isNotEmpty) {
              weatherProvider.addCityForComparison(cityName);
              _citySearchController.clear();
            }
          },
          suffixIcon: weatherProvider.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        if (weatherProvider.errorMessage != null &&
            weatherProvider.currentWeather != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              weatherProvider.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
