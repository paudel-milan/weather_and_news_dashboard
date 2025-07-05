// lib/controllers/weather_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For location services
import 'package:weather_and_news_app/core/services/weather_api_service.dart';
import 'package:weather_and_news_app/models/weather_model.dart';
import 'package:weather_and_news_app/models/forecast_model.dart'; // Import the new forecast models
import 'package:hive_flutter/hive_flutter.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherApiService _apiService =
      WeatherApiService(); // Initialize our API service
  final Box _weatherBox =
      Hive.box('weatherCitiesBox'); // Reference to our Hive box

  Weather? _currentWeather;
  List<HourlyForecast>? _hourlyForecast;
  List<DailyForecast>? _dailyForecast;
  List<Weather> _savedCitiesWeather = []; // For multiple city comparison
  bool _isLoading = false;
  String? _errorMessage;

  Weather? get currentWeather => _currentWeather;
  List<HourlyForecast>? get hourlyForecast => _hourlyForecast;
  List<DailyForecast>? get dailyForecast => _dailyForecast;
  List<Weather> get savedCitiesWeather => _savedCitiesWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor to load initial data or saved cities
  WeatherProvider() {
    _loadSavedCities(); // This will now include loading cached weather/forecasts
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // --- Location and Permission Handling ---
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setErrorMessage('Location services are disabled. Please enable them.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setErrorMessage('Location permissions are denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setErrorMessage(
          'Location permissions are permanently denied. Please enable them from settings.');
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // --- Fetch Weather Data ---
  Future<void> fetchWeatherForCurrentLocation() async {
    _setLoading(true);
    _setErrorMessage(null); // Clear previous errors

    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        // WeatherAPI.com uses "lat,lon" as query string for coordinates
        String query = '${position.latitude},${position.longitude}';
        await _fetchAndSetWeatherData(query);
      } else {
        // If position is null, _setErrorMessage would have already been called by _getCurrentLocation
        // No need for redundant _setLoading(false) here, it's in finally block
      }
    } catch (e) {
      _setErrorMessage('Failed to get location or weather: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWeatherByCityName(String cityName) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // WeatherAPI.com can take city name directly
      await _fetchAndSetWeatherData(cityName);
    } catch (e) {
      _setErrorMessage(
          'Failed to fetch weather for $cityName: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Unified method to fetch and set current, hourly, and daily weather data
  Future<void> _fetchAndSetWeatherData(String query) async {
    try {
      // Fetch current weather
      final weatherData = await _apiService.fetchCurrentWeather(query);
      _currentWeather = weatherData;

      // Fetch hourly forecast
      final hourlyData = await _apiService.fetchHourlyForecast(query);
      _hourlyForecast = hourlyData;

      // Fetch daily forecast (e.g., for 7 days)
      final dailyData = await _apiService.fetchDailyForecast(query, days: 7);
      _dailyForecast = dailyData;

      // Save to Hive
      if (_currentWeather != null) {
        _weatherBox.put('currentWeather', _currentWeather!.toJson());
      } else {
        _weatherBox.delete('currentWeather'); // Clear if no data
      }
      if (_hourlyForecast != null) {
        _weatherBox.put(
            'hourlyForecast', _hourlyForecast!.map((e) => e.toJson()).toList());
      } else {
        _weatherBox.delete('hourlyForecast'); // Clear if no data
      }
      if (_dailyForecast != null) {
        _weatherBox.put(
            'dailyForecast', _dailyForecast!.map((e) => e.toJson()).toList());
      } else {
        _weatherBox.delete('dailyForecast'); // Clear if no data
      }
    } catch (e) {
      _setErrorMessage('Error fetching weather data: ${e.toString()}');
    } finally {
      notifyListeners(); // Notify after all data is potentially updated
    }
  }

  // --- Multiple City Comparison ---
  Future<void> addCityForComparison(String cityName) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final searchResults = await _apiService.searchCity(cityName);
      if (searchResults.isEmpty) {
        _setErrorMessage('No city found for "$cityName".');
        return;
      }

      final bestMatch = searchResults.first;
      String queryForWeather = '${bestMatch['lat']},${bestMatch['lon']}';
      String nameForComparison = bestMatch['name'];

      if (_savedCitiesWeather.any((city) =>
          city.cityName?.toLowerCase() == nameForComparison.toLowerCase())) {
        _setErrorMessage(
            '$nameForComparison is already in your comparison list.');
        return;
      }

      final weatherData =
          await _apiService.fetchCurrentWeather(queryForWeather);
      if (weatherData != null) {
        _savedCitiesWeather.add(weatherData);
        _saveCitiesToHive();
      } else {
        _setErrorMessage('Failed to fetch weather for $nameForComparison.');
      }
    } catch (e) {
      _setErrorMessage('Could not add $cityName: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void removeCityFromComparison(String cityName) {
    _savedCitiesWeather.removeWhere(
        (city) => city.cityName?.toLowerCase() == cityName.toLowerCase());
    _saveCitiesToHive();
    notifyListeners();
  }

  // --- Hive (Local Storage) Integration ---
  void _loadSavedCities() {
    // Load saved comparison cities
    final List<dynamic>? savedCitiesJson = _weatherBox.get('savedCities');
    if (savedCitiesJson != null) {
      _savedCitiesWeather = savedCitiesJson
          .map((json) {
            if (json is Map<String, dynamic>) {
              try {
                return Weather.fromJson(json);
              } catch (e) {
                debugPrint(
                    'Error parsing saved city Weather JSON: $e, data: $json');
                return null; // Return null if parsing fails
              }
            }
            debugPrint(
                'Warning: Skipped non-Map or null entry in savedCitiesJson: $json');
            return null; // Skip if not a Map or is null
          })
          .whereType<Weather>() // Filter out any nulls from failed parsing
          .toList();
    }

    // Also attempt to load cached current weather and forecast
    final currentWeatherJson = _weatherBox.get('currentWeather');
    if (currentWeatherJson != null &&
        currentWeatherJson is Map<String, dynamic>) {
      try {
        _currentWeather = Weather.fromJson(currentWeatherJson);
      } catch (e) {
        debugPrint(
            'Error parsing cached current Weather JSON: $e, data: $currentWeatherJson');
        _weatherBox.delete('currentWeather'); // Clear corrupted data
      }
    }

    final hourlyForecastJson = _weatherBox.get('hourlyForecast') as List?;
    if (hourlyForecastJson != null) {
      _hourlyForecast = hourlyForecastJson
          .map((json) {
            if (json is Map<String, dynamic>) {
              try {
                return HourlyForecast.fromJson(json);
              } catch (e) {
                debugPrint(
                    'Error parsing cached HourlyForecast JSON: $e, data: $json');
                return null;
              }
            }
            debugPrint(
                'Warning: Skipped non-Map or null entry in hourlyForecastJson: $json');
            return null;
          })
          .whereType<HourlyForecast>()
          .toList();
    }

    final dailyForecastJson = _weatherBox.get('dailyForecast') as List?;
    if (dailyForecastJson != null) {
      _dailyForecast = dailyForecastJson
          .map((json) {
            if (json is Map<String, dynamic>) {
              try {
                return DailyForecast.fromJson(json);
              } catch (e) {
                debugPrint(
                    'Error parsing cached DailyForecast JSON: $e, data: $json');
                return null;
              }
            }
            debugPrint(
                'Warning: Skipped non-Map or null entry in dailyForecastJson: $json');
            return null;
          })
          .whereType<DailyForecast>()
          .toList();
    }
    notifyListeners();
  }

  void _saveCitiesToHive() {
    _weatherBox.put(
        'savedCities', _savedCitiesWeather.map((e) => e.toJson()).toList());
  }

  // --- Refresh Function for Pull-to-Refresh ---
  Future<void> refreshWeatherData() async {
    _setLoading(true); // Indicate loading for refresh
    _setErrorMessage(null); // Clear previous errors

    try {
      // Determine how to refresh based on current state
      if (_currentWeather != null &&
          _currentWeather!.lat != null &&
          _currentWeather!.lon != null) {
        String query = '${_currentWeather!.lat!},${_currentWeather!.lon!}';
        await _fetchAndSetWeatherData(query);
      } else {
        await fetchWeatherForCurrentLocation(); // Try to get location again
      }

      // Refresh saved cities weather as well
      List<Weather> refreshedSavedCities = [];
      for (var city in _savedCitiesWeather) {
        try {
          if (city.cityName != null) {
            final refreshedWeather =
                await _apiService.fetchCurrentWeather(city.cityName!);
            if (refreshedWeather != null) {
              refreshedSavedCities.add(refreshedWeather);
            } else {
              // If refresh fails for a city (e.g., API error), keep the old data
              refreshedSavedCities.add(city);
            }
          } else {
            debugPrint(
                'Skipping saved city with null cityName during refresh.');
          }
        } catch (e) {
          debugPrint('Failed to refresh weather for ${city.cityName}: $e');
          // If refresh fails for a city, keep the old data
          refreshedSavedCities.add(city);
        }
      }
      _savedCitiesWeather =
          refreshedSavedCities; // Update the list with refreshed data
      _saveCitiesToHive(); // Save updated saved cities
    } catch (e) {
      _setErrorMessage('Failed to refresh data: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

}
