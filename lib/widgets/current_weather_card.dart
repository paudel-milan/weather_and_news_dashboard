// lib/widgets/current_weather_card.dart

import 'package:flutter/material.dart';
import 'package:weather_and_news_app/models/weather_model.dart';
import 'package:shimmer/shimmer.dart'; // For shimmer loading effect
import 'package:intl/intl.dart'; // For date formatting
import 'package:cached_network_image/cached_network_image.dart'; // Recommended for network images

class CurrentWeatherCard extends StatelessWidget {
  final Weather? weather;
  final bool isLoading;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading || weather == null
            ? _buildShimmerLoading(context)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Location
                  Text(
                    weather!.cityName ?? 'Unknown Location', // Changed from weather!.name
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Date and Time
                  Text(
                    weather!.lastUpdatedEpoch != null
                        ? DateFormat('EEEE, MMMM d, hh:mm a').format(
                            // WeatherAPI.com timestamp is epoch in seconds, convert to milliseconds
                            DateTime.fromMillisecondsSinceEpoch(
                                weather!.lastUpdatedEpoch! * 1000))
                        : 'Loading Date...',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Weather Icon and Temperature
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (weather!.iconUrl != null) // Use weather!.iconUrl directly
                        CachedNetworkImage( // Using CachedNetworkImage
                          imageUrl: weather!.iconUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator.adaptive(strokeWidth: 2),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.cloud_off, size: 80),
                        )
                      else
                        const Icon(Icons.cloud, size: 100), // Default icon if no URL
                      const SizedBox(width: 10),
                      Text(
                        weather!.temperature != null // Changed from weather!.temp
                            ? '${weather!.temperature!.round()}°C'
                            : '--°C',
                        style: textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Weather Description
                  Text(
                    weather!.conditionText != null // Changed from weather!.description
                        ? weather!.conditionText!.toUpperCase()
                        : 'LOADING CONDITIONS',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Min/Max Temperature
                  Text(
                    weather!.tempMin != null && weather!.tempMax != null
                        ? 'Min: ${weather!.tempMin!.round()}°C / Max: ${weather!.tempMax!.round()}°C'
                        : 'Min: --°C / Max: --°C',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),

                  // Additional Details (Humidity, Wind Speed, Feels Like)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailColumn(
                        context,
                        Icons.water_drop,
                        weather!.humidity != null
                            ? '${weather!.humidity!}%'
                            : '--%',
                        'Humidity',
                      ),
                      _buildDetailColumn(
                        context,
                        Icons.wind_power,
                        weather!.windSpeedKph != null // Changed from windSpeed
                            ? '${weather!.windSpeedKph!.toStringAsFixed(1)} km/h' // Changed unit
                            : '-- km/h',
                        'Wind',
                      ),
                      _buildDetailColumn(
                        context,
                        Icons.thermostat,
                        weather!.feelsLike != null
                            ? '${weather!.feelsLike!.round()}°C'
                            : '--°C',
                        'Feels Like',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailColumn(
      BuildContext context, IconData icon, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 30, color: colorScheme.primary),
        const SizedBox(height: 5),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 24,
            color: Colors.white,
          ), // Location
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 16,
            color: Colors.white,
          ), // Date and Time
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ), // Icon
              const SizedBox(width: 10),
              Container(
                width: 150,
                height: 60,
                color: Colors.white,
              ), // Temperature
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: 200,
            height: 20,
            color: Colors.white,
          ), // Description
          const SizedBox(height: 20),
          Container(
            width: 180,
            height: 16,
            color: Colors.white,
          ), // Min/Max
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  Container(width: 30, height: 30, color: Colors.white), // Icon
                  const SizedBox(height: 5),
                  Container(width: 50, height: 16, color: Colors.white), // Value
                  Container(width: 40, height: 12, color: Colors.white), // Label
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}