// lib/widgets/hourly_forecast_list.dart

import 'package:flutter/material.dart';
import 'package:weather_and_news_app/models/forecast_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast>? forecasts;
  final bool isLoading;

  const HourlyForecastList({
    super.key,
    required this.forecasts,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || forecasts == null || forecasts!.isEmpty) {
      return _buildShimmerLoading(context);
    }

    final List<HourlyForecast> relevantForecasts =
        forecasts!.where((f) => f.timestamp != null).take(24).toList();

    if (relevantForecasts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No hourly forecast data available.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120, // Fixed height for the horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relevantForecasts.length,
        itemBuilder: (context, index) {
          final hourlyForecast = relevantForecasts[index];
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
              hourlyForecast.timestamp! * 1000);

          final bool isCurrentHour = dateTime.hour == DateTime.now().hour &&
              dateTime.day == DateTime.now().day;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: 80,
              height: 105, // Container height remains 105
              padding: const EdgeInsets.all(8.0), // Padding remains 8.0
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCurrentHour ? 'Now' : DateFormat('h a').format(dateTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isCurrentHour
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5), // <--- CHANGED FROM 8 to 5
                  if (hourlyForecast.condition?.fullIconUrl != null)
                    CachedNetworkImage(
                      imageUrl: hourlyForecast.condition!.fullIconUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator.adaptive(
                              strokeWidth: 2),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.cloud_off, size: 30),
                    )
                  else
                    const Icon(Icons.cloud, size: 40),
                  const SizedBox(height: 5), // <--- CHANGED FROM 8 to 5
                  Text(
                    hourlyForecast.tempC != null
                        ? '${hourlyForecast.tempC!.round()}°C'
                        : '--°C',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: 80,
              height: 105, // This also needs to match, so it's consistent
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 16,
                    color: Colors.white,
                  ), // Time
                  const SizedBox(height: 5), // <--- CHANGED FROM 8 to 5
                  Container(
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  ), // Icon
                  const SizedBox(height: 5), // <--- CHANGED FROM 8 to 5
                  Container(
                    width: 40,
                    height: 20,
                    color: Colors.white,
                  ), // Temperature
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
