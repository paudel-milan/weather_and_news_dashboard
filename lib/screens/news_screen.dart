// lib/screens/news_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_and_news_app/controllers/news_provider.dart';
import 'package:weather_and_news_app/widgets/search_input_field.dart'; // Re-use our search input
import 'package:weather_and_news_app/widgets/news_article_card.dart'; // We'll create this next
import 'package:shimmer/shimmer.dart'; // For shimmer effect on news list

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = const [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology'
  ];

  @override
  void initState() {
    super.initState();
    // No need to fetch here, NewsProvider fetches in its constructor
    // and when category changes.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Dashboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110.0), // Height for search bar and categories
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                SearchInputField(
                  controller: _searchController,
                  hintText: 'Search for articles...',
                  onChanged: (query) {
                    Provider.of<NewsProvider>(context, listen: false)
                        .searchArticlesDebounced(query);
                  },
                  onSubmitted: (query) {
                    // Optional: You can trigger search immediately on submit if preferred
                    // But debounced search already covers this effectively
                  },
                  suffixIcon: Consumer<NewsProvider>(
                    builder: (context, newsProvider, child) {
                      return newsProvider.isLoadingSearch
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    newsProvider.searchArticlesDebounced(''); // Clear search results
                                  },
                                )
                              : const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40, // Height for category chips
                  child: Consumer<NewsProvider>(
                    builder: (context, newsProvider, child) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category == newsProvider.selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(category.capitalizeFirst),
                              selected: isSelected,
                              selectedColor: Theme.of(context).primaryColor,
                              onSelected: (selected) {
                                if (selected) {
                                  // Clear search results when switching categories
                                  _searchController.clear();
                                  newsProvider.searchArticlesDebounced('');
                                  newsProvider.fetchTopHeadlines(category: category);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          List<dynamic> articlesToDisplay;
          bool isLoading;
          String? errorMessage;

          if (_searchController.text.isNotEmpty) {
            articlesToDisplay = newsProvider.searchedArticles;
            isLoading = newsProvider.isLoadingSearch;
            errorMessage = newsProvider.searchErrorMessage;
          } else {
            articlesToDisplay = newsProvider.topHeadlines;
            isLoading = newsProvider.isLoadingHeadlines;
            errorMessage = newsProvider.headlinesErrorMessage;
          }

          if (isLoading && articlesToDisplay.isEmpty) {
            // Show shimmer loading if actively loading and no existing data
            return _buildShimmerLoading();
          }

          if (errorMessage != null && articlesToDisplay.isEmpty) {
            // Show error message if loading failed and no data is cached
            return RefreshIndicator(
              onRefresh: newsProvider.refreshHeadlines,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            );
          }

          if (articlesToDisplay.isEmpty) {
            return RefreshIndicator(
              onRefresh: newsProvider.refreshHeadlines,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? 'No articles found for "${_searchController.text}".'
                          : 'No news headlines available. Check your internet connection or try again later.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: newsProvider.refreshHeadlines,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: articlesToDisplay.length,
              itemBuilder: (context, index) {
                final article = articlesToDisplay[index];
                return NewsArticleCard(
                  article: article,
                  onBookmarkToggle: newsProvider.toggleBookmark,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5, // Show 5 shimmer items
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 180, // Approximate height of a news card
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Re-using the StringCasingExtension from weather_screen,
// or you can put it in a separate utility file if preferred.
extension StringCasingExtension on String {
  String get capitalizeFirstofEach => split(" ").map((str) => str.capitalizeFirst).join(" ");
  String get capitalizeFirst => isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}