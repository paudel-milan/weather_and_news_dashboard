// lib/core/constants/api_constants.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String weatherApiComApiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  static final String weatherApiComBaseUrl = dotenv.env['WEATHER_API_BASE_URL'] ?? '';

  static final String newsApiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static final String newsApiBaseUrl = dotenv.env['NEWS_API_BASE_URL'] ?? '';
}
