// lib/core/services/weather_api_service.dart

import 'package:dio/dio.dart';
import 'package:weather_and_news_app/core/constants/api_constants.dart';
import 'package:weather_and_news_app/models/weather_model.dart';
import 'package:weather_and_news_app/models/forecast_model.dart';

class WeatherApiService {
  final Dio _dio;

  // Initialize Dio with WeatherAPI.com's base URL
  WeatherApiService([Dio? dio]) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConstants.weatherApiComBaseUrl;
  }

  // Helper to handle Dio errors
  void _handleDioError(DioException e) {
    if (e.response != null) {
      // The server responded with a status code other than 2xx
      String errorMessage = 'API Error: ${e.response!.statusCode}';
      if (e.response!.data != null && e.response!.data is Map) {
        // Attempt to extract more specific error message from WeatherAPI.com response
        if (e.response!.data.containsKey('error')) {
          errorMessage =
              'API Error: ${e.response!.data['error']['code']} - ${e.response!.data['error']['message']}';
        } else {
          errorMessage =
              'API Error: ${e.response!.statusCode} - ${e.response!.data.toString()}';
        }
      } else {
        errorMessage =
            'API Error: ${e.response!.statusCode} - ${e.response!.statusMessage}';
      }
      throw Exception(errorMessage);
    } else if (e.type == DioExceptionType.connectionError) {
      // No internet connection or host not found
      throw Exception(
          'Network Error: Please check your internet connection or the server is unreachable.');
    } else if (e.type == DioExceptionType.cancel) {
      throw Exception('Request cancelled.');
    } else if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw Exception('Connection timeout. Please try again.');
    } else {
      // Other errors
      throw Exception('An unexpected error occurred: ${e.message}');
    }
  }

  // --- Core Data Fetching from WeatherAPI.com (Unified Endpoint) ---
  // This method fetches current, hourly, and daily forecast data in one go.
  // 'query' can be a city name, 'lat,lon' string, or IP address.
  Future<Map<String, dynamic>> _fetchRawWeatherData(String query,
      {int days = 7}) async {
    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': ApiConstants.weatherApiComApiKey,
          'q': query,
          'days': days.toString(), // <--- **CHANGED THIS LINE**
          'aqi': 'no', // Disable Air Quality Index
          'alerts': 'no', // Disable weather alerts
        },
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception(
            'Failed to retrieve weather data: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow; // Re-throw the handled exception
    } catch (e) {
      throw Exception('Failed to fetch raw weather data: $e');
    }
  }

  // --- Specific Data Extraction Methods for Your Models ---

  // Fetches current weather for a given location (city name or lat,lon)
  Future<Weather?> fetchCurrentWeather(String query) async {
    try {
      final data = await _fetchRawWeatherData(query,
          days: 1); // Only need 1 day for current data
      return Weather.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch current weather for "$query": $e');
    }
  }

  // Fetches hourly forecast for a given location (city name or lat,lon)
  Future<List<HourlyForecast>?> fetchHourlyForecast(String query) async {
    try {
      // Fetch 2 days of forecast to ensure we have enough hourly data for 24-48 hours
      final data = await _fetchRawWeatherData(query, days: 2);
      final List<HourlyForecast> hourlyList = [];

      if (data.containsKey('forecast') &&
          data['forecast'].containsKey('forecastday')) {
        for (var dayData in data['forecast']['forecastday']) {
          if (dayData.containsKey('hour')) {
            for (var hourData in dayData['hour']) {
              hourlyList.add(HourlyForecast.fromJson(hourData));
            }
          }
        }
      }
      return hourlyList;
    } catch (e) {
      throw Exception('Failed to fetch hourly forecast for "$query": $e');
    }
  }

  // Fetches daily forecast for a given location (city name or lat,lon)
  Future<List<DailyForecast>?> fetchDailyForecast(String query,
      {int days = 7}) async {
    try {
      final data = await _fetchRawWeatherData(query,
          days: days); // Fetch specified number of days
      final List<DailyForecast> dailyList = [];

      if (data.containsKey('forecast') &&
          data['forecast'].containsKey('forecastday')) {
        for (var dayData in data['forecast']['forecastday']) {
          dailyList.add(DailyForecast.fromJson(dayData));
        }
      }
      return dailyList;
    } catch (e) {
      throw Exception('Failed to fetch daily forecast for "$query": $e');
    }
  }

  // --- Geocoding (City Search) ---
  // WeatherAPI.com offers a search endpoint for city names
  Future<List<Map<String, dynamic>>> searchCity(String cityName) async {
    try {
      final response = await _dio.get(
        '/search.json',
        queryParameters: {
          'key': ApiConstants.weatherApiComApiKey,
          'q': cityName,
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to search city: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('Failed to search city: $e');
    }
  }
}
