// lib/screens/bookmarks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_and_news_app/controllers/news_provider.dart';
import 'package:weather_and_news_app/widgets/news_article_card.dart'; // Reuse the news article card

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          final bookmarkedArticles = newsProvider.bookmarkedArticles;

          if (bookmarkedArticles.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                // Bookmarks are loaded on NewsProvider init.
                // For a simple refresh, we can just notify listeners
                // or if you ever integrate cloud sync for bookmarks,
                // you'd trigger that here. For now, it mainly
                // allows pull to refresh to show a message if empty.
                newsProvider.notifyListeners();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh even when empty
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No articles bookmarked yet.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find interesting articles in the News section and tap the bookmark icon to save them here.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // This refresh just causes the NewsProvider to rebuild its state,
              // which re-reads bookmarks from Hive. If you had an async cloud sync,
              // you'd trigger that here.
              newsProvider.notifyListeners();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final article = bookmarkedArticles[index];
                return NewsArticleCard(
                  article: article,
                  onBookmarkToggle: newsProvider.toggleBookmark,
                  // onTap: () => Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ArticleDetailScreen(articleUrl: article.url!),
                  //   ),
                  // ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}