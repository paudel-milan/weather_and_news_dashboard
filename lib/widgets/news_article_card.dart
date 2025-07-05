// lib/widgets/news_article_card.dart

import 'package:flutter/material.dart';
import 'package:weather_and_news_app/models/news_article_model.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cached_network_image/cached_network_image.dart'; // For better image loading

class NewsArticleCard extends StatelessWidget {
  final NewsArticle article;
  final Function(NewsArticle article) onBookmarkToggle;
  final VoidCallback? onTap; // Optional callback for tapping the card

  const NewsArticleCard({
    super.key,
    required this.article,
    required this.onBookmarkToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell( // Use InkWell for tap feedback
        onTap: onTap, // Handled by a dedicated article detail screen later
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    fit: BoxFit.cover,
                    height: 180,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: colorScheme.surfaceContainerHighest, // Placeholder color
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.broken_image, size: 50, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(Icons.newspaper, size: 80, color: colorScheme.onSurfaceVariant),
                ),
              const SizedBox(height: 12),

              // Article Title
              Text(
                article.title ?? 'No Title',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Source and Published At
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      article.source?.name ?? 'Unknown Source',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    article.publishedAt != null
                        ? DateFormat('MMM dd, yyyy').format(article.publishedAt!)
                        : 'Unknown Date',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Bookmark Button
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: article.isBookmarked ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                  onPressed: () => onBookmarkToggle(article),
                  tooltip: article.isBookmarked ? 'Remove from bookmarks' : 'Add to bookmarks',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}