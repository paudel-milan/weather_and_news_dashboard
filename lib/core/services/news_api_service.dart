// lib/core/services/news_api_service.dart

import 'package:dio/dio.dart';
import 'package:weather_and_news_app/core/constants/api_constants.dart';
import 'package:weather_and_news_app/models/news_article_model.dart';

class NewsApiService {
  final Dio _dio;

  NewsApiService([Dio? dio]) : _dio = dio ?? Dio();

  // Helper to handle Dio errors
  void _handleDioError(DioException e) {
    if (e.response != null) {
      // The server responded with a status code other than 2xx
      String errorMessage = 'API Error: ${e.response!.statusCode}';
      if (e.response!.data != null && e.response!.data is Map && e.response!.data.containsKey('message')) {
        errorMessage += ' - ${e.response!.data['message']}';
      } else {
        errorMessage += ' - ${e.response!.data}';
      }
      throw Exception(errorMessage);
    } else if (e.type == DioExceptionType.connectionError) {
      // No internet connection or host not found
      throw Exception('Network Error: Please check your internet connection.');
    } else {
      // Other errors
      throw Exception('An unexpected error occurred: ${e.message}');
    }
  }

  /// Fetches top headlines based on category and optional query.
  /// category: Can be 'business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology'.
  ///           If null, fetches general top headlines.
  /// query: Optional search term.
  Future<List<NewsArticle>> fetchTopHeadlines({String? category, String? query}) async {
    try {
      Map<String, dynamic> queryParams = {
        'apiKey': ApiConstants.newsApiKey,
        'country': 'us', // Can be made configurable if needed
      };

      String endpoint = '/top-headlines';

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await _dio.get(
        '${ApiConstants.newsApiBaseUrl}$endpoint',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final NewsApiResponse apiResponse = NewsApiResponse.fromJson(response.data);
        if (apiResponse.status == 'ok' && apiResponse.articles != null) {
          return apiResponse.articles!;
        } else {
          throw Exception('News API returned an error: ${apiResponse.status}');
        }
      } else {
        throw Exception('Failed to fetch top headlines: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow; // Re-throw after handling for provider to catch
    } catch (e) {
      throw Exception('An error occurred while fetching top headlines: $e');
    }
  }

  /// Searches for news articles based on a query.
  /// query: The search term.
  /// sortBy: 'relevancy', 'popularity', 'publishedAt'.
  Future<List<NewsArticle>> searchArticles(String query, {String sortBy = 'publishedAt'}) async {
    if (query.isEmpty) return []; // Don't search if query is empty
    try {
      final response = await _dio.get(
        '${ApiConstants.newsApiBaseUrl}/everything',
        queryParameters: {
          'q': query,
          'sortBy': sortBy,
          'apiKey': ApiConstants.newsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final NewsApiResponse apiResponse = NewsApiResponse.fromJson(response.data);
        if (apiResponse.status == 'ok' && apiResponse.articles != null) {
          return apiResponse.articles!;
        } else {
          throw Exception('News API returned an error: ${apiResponse.status}');
        }
      } else {
        throw Exception('Failed to search articles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow; // Re-throw after handling for provider to catch
    } catch (e) {
      throw Exception('An error occurred while searching articles: $e');
    }
  }
}