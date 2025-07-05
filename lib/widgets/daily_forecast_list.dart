// lib/widgets/daily_forecast_list.dart

import 'package:flutter/material.dart';
import 'package:weather_and_news_app/models/forecast_model.dart'; // Using DailyForecast model
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Recommended for network images

class DailyForecastList extends StatelessWidget {
  final List<DailyForecast>? forecasts; // Note: using DailyForecast here
  final bool isLoading;

  const DailyForecastList({
    super.key,
    required this.forecasts,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || forecasts == null || forecasts!.isEmpty) {
      return _buildShimmerLoading(context);
    }

    // Filter to show next 7 days (or up to 7 if more are returned)
    // We skip the first element if it's for the current day, as current weather handles today.
    final List<DailyForecast> relevantForecasts = forecasts!
        .where((f) => f.timestamp != null)
        .skip(
            1) // Skip today's entry as it's typically covered by current weather
        .take(7) // Display up to next 7 daily forecasts
        .toList();

    if (relevantForecasts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No daily forecast data available.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap:
          true, // Important to make ListView fit its content inside Column
      physics:
          const NeverScrollableScrollPhysics(), // Managed by parent SingleChildScrollView
      itemCount: relevantForecasts.length,
      itemBuilder: (context, index) {
        final forecast = relevantForecasts[index];
        final dateTime =
            DateTime.fromMillisecondsSinceEpoch(forecast.timestamp! * 1000);
        final isTomorrow = DateUtils.isSameDay(
            dateTime, DateTime.now().add(const Duration(days: 1)));

        // Access icon and min/max temps from daySummary
        final String? iconUrl = forecast.daySummary?.condition?.fullIconUrl;
        final double? minTemp = forecast.daySummary?.minTempC;
        final double? maxTemp = forecast.daySummary?.maxTempC;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              // This is the main Row that was overflowing
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Day of the week
                Expanded(
                  flex: 2,
                  child: Text(
                    isTomorrow
                        ? 'Tomorrow'
                        : DateFormat('EEEE').format(dateTime),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    maxLines:
                        1, // Added: Ensure text doesn't wrap and overflow vertically
                    overflow: TextOverflow
                        .ellipsis, // Added: Truncate with ellipsis if it overflows horizontally
                  ),
                ),
                // Weather Icon and Description (using daySummary's condition)
                Expanded(
                  flex: 2,
                  child: Row(
                    // This is the inner Row that was reported as overflowing
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize
                        .min, // **** CRITICAL FIX: Make inner Row shrink to its children's size ****
                    children: [
                      if (iconUrl != null)
                        CachedNetworkImage(
                          // Using CachedNetworkImage
                          imageUrl: iconUrl,
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
                        const Icon(Icons.cloud, size: 40), // Default icon
                      const SizedBox(width: 8),
                      // Optional: display short description if space allows
                      // If you uncomment this, make sure to wrap it in an Expanded widget
                      if (forecast.daySummary?.condition?.text != null)
                        Expanded(
                          // <--- If uncommenting, wrap Text in Expanded
                          child: Text(
                            forecast.daySummary!.condition!.text!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                ),
                // Min/Max Temperature
                Expanded(
                  flex: 1,
                  child: Text(
                    minTemp != null && maxTemp != null
                        ? '${minTemp.round()}° / ${maxTemp.round()}°C'
                        : '--° / --°°C', // Corrected: ensure a default for both min/max
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.right,
                    maxLines: 1, // Added: Ensure text doesn't wrap
                    overflow: TextOverflow
                        .ellipsis, // Added: Truncate if it overflows
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7, // Show 7 shimmer items
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 20,
                  color: Colors.white,
                ), // Day
                Row(
                  // This Row also needs MainAxisSize.min for shimmer if it represents a similar layout
                  mainAxisSize: MainAxisSize
                      .min, // Added for consistency with the actual forecast Row
                  children: [
                    Container(
                        width: 40, height: 40, color: Colors.white), // Icon
                    const SizedBox(width: 8),
                    // If you uncomment the description in the main build method, you might need a shimmer placeholder here too
                    // Container(width: 60, height: 16, color: Colors.white), // Description (optional)
                  ],
                ),
                Container(
                  width: 70,
                  height: 20,
                  color: Colors.white,
                ), // Min/Max
              ],
            ),
          ),
        ),
      ),
    );
  }
}
