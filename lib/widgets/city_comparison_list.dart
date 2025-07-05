// lib/widgets/city_comparison_list.dart

import 'package:flutter/material.dart';
import 'package:weather_and_news_app/models/weather_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Recommended for network images

class CityComparisonList extends StatelessWidget {
  final List<Weather> citiesWeather;
  final Function(String cityName) onRemove;

  const CityComparisonList({
    super.key,
    required this.citiesWeather,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (citiesWeather.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No cities saved for comparison. Search a city above to add it!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Handled by parent SingleChildScrollView
      itemCount: citiesWeather.length,
      itemBuilder: (context, index) {
        final weather = citiesWeather[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Weather Icon
                if (weather.iconUrl != null) // Check if iconUrl is available
                  CachedNetworkImage( // Use CachedNetworkImage for better performance
                    imageUrl: weather.iconUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain, // Ensure image fits without distortion
                    placeholder: (context, url) => const CircularProgressIndicator.adaptive(strokeWidth: 2), // Show loading
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.cloud_off, size: 30),
                  )
                else
                  const Icon(Icons.cloud, size: 40), // Default icon if no URL
                const SizedBox(width: 12),
                // City Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.cityName ?? 'Unknown City',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      // Optional: Small description
                      if (weather.conditionText != null) // Changed from description to conditionText
                        Text(
                          weather.conditionText!.capitalizeFirstofEach, // Helper below
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Temperature
                Text(
                  weather.temperature != null
                      ? '${weather.temperature!.round()}°C'
                      : '--°C',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                // Remove Button
                IconButton(
                  icon: Icon(Icons.close,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: () {
                    if (weather.cityName != null) {
                      onRemove(weather.cityName!);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extension to capitalize the first letter of each word
extension StringCasingExtension on String {
  String get capitalizeFirstofEach => split(" ").map((str) => str.capitalizeFirst).join(" ");
  String get capitalizeFirst => isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}