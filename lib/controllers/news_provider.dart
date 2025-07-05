// lib/controllers/news_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_and_news_app/core/services/news_api_service.dart';
import 'package:weather_and_news_app/models/news_article_model.dart';
import 'package:debounce_throttle/debounce_throttle.dart'; // For debouncing search

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService = NewsApiService();
  final Box _newsBox = Hive.box('newsBox'); // Reference to our Hive box

  List<NewsArticle> _topHeadlines = [];
  List<NewsArticle> _searchedArticles = [];
  List<NewsArticle> _bookmarkedArticles = [];
  String _selectedCategory = 'general'; // Default category
  bool _isLoadingHeadlines = false;
  bool _isLoadingSearch = false;
  String? _headlinesErrorMessage;
  String? _searchErrorMessage;

  // Debouncer for search input
  late final Debouncer<String> _searchDebouncer;


  List<NewsArticle> get topHeadlines => _topHeadlines;
  List<NewsArticle> get searchedArticles => _searchedArticles;
  List<NewsArticle> get bookmarkedArticles => _bookmarkedArticles;
  String get selectedCategory => _selectedCategory;
  bool get isLoadingHeadlines => _isLoadingHeadlines;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get headlinesErrorMessage => _headlinesErrorMessage;
  String? get searchErrorMessage => _searchErrorMessage;


  NewsProvider() {
    _searchDebouncer = Debouncer<String>(
      const Duration(milliseconds: 500),
      initialValue: '',
      onChanged: (query) {
        if (query.isNotEmpty) {
          _performSearch(query);
        } else {
          // Clear search results if query is empty
          _searchedArticles = [];
          notifyListeners();
        }
      },
    );
    _loadBookmarkedArticles();
    fetchTopHeadlines(category: _selectedCategory); // Fetch initial headlines
  }

  void _setLoadingSearch(bool value) {
    _isLoadingSearch = value;
    notifyListeners();
  }

  void _setLoadingHeadlines(bool value) {
    _isLoadingHeadlines = value;
    notifyListeners();
  }

  void _setHeadlinesErrorMessage(String? message) {
    _headlinesErrorMessage = message;
    notifyListeners();
  }

  void _setSearchErrorMessage(String? message) {
    _searchErrorMessage = message;
    notifyListeners();
  }

  // --- Fetching News ---

  Future<void> fetchTopHeadlines({String? category}) async {
    _setLoadingHeadlines(true);
    _setHeadlinesErrorMessage(null);

    // If a category is provided, update the selected category
    if (category != null && category != _selectedCategory) {
      _selectedCategory = category;
      _topHeadlines = []; // Clear previous headlines when category changes
    }

    try {
      final List<NewsArticle> fetchedArticles = await _apiService.fetchTopHeadlines(
        category: _selectedCategory,
      );
      _topHeadlines = _mergeWithBookmarks(fetchedArticles);
    } catch (e) {
      _setHeadlinesErrorMessage('Failed to fetch headlines: ${e.toString()}');
    } finally {
      _setLoadingHeadlines(false);
    }
  }

  // Method to be called from UI when search input changes
  void searchArticlesDebounced(String query) {
    _searchDebouncer.value = query;
  }

  // Actual search logic, called by the debouncer
  Future<void> _performSearch(String query) async {
    _setLoadingSearch(true);
    _setSearchErrorMessage(null);

    try {
      final List<NewsArticle> fetchedArticles = await _apiService.searchArticles(query);
      _searchedArticles = _mergeWithBookmarks(fetchedArticles);
    } catch (e) {
      _setSearchErrorMessage('Failed to search articles: ${e.toString()}');
    } finally {
      _setLoadingSearch(false);
    }
  }

  // --- Bookmark Management ---

  void toggleBookmark(NewsArticle article) {
    int indexInBookmarks = _bookmarkedArticles.indexWhere((bArticle) => bArticle.uniqueId == article.uniqueId);

    if (indexInBookmarks != -1) {
      // Article is already bookmarked, so unbookmark it
      _bookmarkedArticles.removeAt(indexInBookmarks);
      article.isBookmarked = false;
    } else {
      // Article is not bookmarked, so bookmark it
      article.isBookmarked = true;
      _bookmarkedArticles.add(article);
    }
    _saveBookmarksToHive();
    // Update the original lists (topHeadlines and searchedArticles) to reflect the bookmark change
    _topHeadlines = _mergeWithBookmarks(_topHeadlines);
    _searchedArticles = _mergeWithBookmarks(_searchedArticles);
    notifyListeners(); // Notify UI of changes
  }

  void _loadBookmarkedArticles() {
    final List<dynamic>? storedBookmarks = _newsBox.get('bookmarkedArticles');
    if (storedBookmarks != null) {
      _bookmarkedArticles = storedBookmarks
          .map((json) => NewsArticle.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      // Ensure all loaded bookmarks are marked as bookmarked
      for (var article in _bookmarkedArticles) {
        article.isBookmarked = true;
      }
    }
    notifyListeners();
  }

  void _saveBookmarksToHive() {
    _newsBox.put('bookmarkedArticles', _bookmarkedArticles.map((e) => e.toJson()).toList());
  }

  // Helper to mark articles in fetched lists if they are bookmarked
  List<NewsArticle> _mergeWithBookmarks(List<NewsArticle> articles) {
    return articles.map((article) {
      final bool isBookmarked = _bookmarkedArticles.any((bArticle) => bArticle.uniqueId == article.uniqueId);
      return NewsArticle(
        source: article.source,
        author: article.author,
        title: article.title,
        description: article.description,
        url: article.url,
        imageUrl: article.imageUrl,
        publishedAt: article.publishedAt,
        content: article.content,
        isBookmarked: isBookmarked, // Set this based on actual bookmark status
      );
    }).toList();
  }

  // --- Refresh Function for Pull-to-Refresh ---
  Future<void> refreshHeadlines() async {
    await fetchTopHeadlines(category: _selectedCategory);
    // Note: Search results are not typically 'refreshed' by pull-to-refresh
    // unless the search query is explicitly re-entered.
    // If a search is active, you might want to re-run _performSearch(_searchDebouncer.value);
  }

  @override
  void dispose() {
    // _newsBox.close(); // Only if you explicitly manage closing
    super.dispose();
  }
}