// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HourlyForecast _$HourlyForecastFromJson(Map<String, dynamic> json) =>
    HourlyForecast(
      timestamp: (json['time_epoch'] as num?)?.toInt(),
      timeString: json['time'] as String?,
      tempC: (json['temp_c'] as num?)?.toDouble(),
      feelsLikeC: (json['feelslike_c'] as num?)?.toDouble(),
      pressureMb: (json['pressure_mb'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      dewPointC: (json['dewpoint_c'] as num?)?.toDouble(),
      uv: (json['uv'] as num?)?.toDouble(),
      clouds: (json['cloud'] as num?)?.toInt(),
      visibilityKm: (json['vis_km'] as num?)?.toDouble(),
      windSpeedKph: (json['wind_kph'] as num?)?.toDouble(),
      windDegrees: (json['wind_degree'] as num?)?.toInt(),
      windGustKph: (json['gust_kph'] as num?)?.toDouble(),
      precipitationMm: (json['precip_mm'] as num?)?.toDouble(),
      chanceOfRain: (json['chance_of_rain'] as num?)?.toInt(),
      chanceOfSnow: (json['chance_of_snow'] as num?)?.toInt(),
      condition: json['condition'] == null
          ? null
          : WeatherCondition.fromJson(
              json['condition'] as Map<String, dynamic>),
      isDay: (json['is_day'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HourlyForecastToJson(HourlyForecast instance) =>
    <String, dynamic>{
      'time_epoch': instance.timestamp,
      'time': instance.timeString,
      'temp_c': instance.tempC,
      'feelslike_c': instance.feelsLikeC,
      'pressure_mb': instance.pressureMb,
      'humidity': instance.humidity,
      'dewpoint_c': instance.dewPointC,
      'uv': instance.uv,
      'cloud': instance.clouds,
      'vis_km': instance.visibilityKm,
      'wind_kph': instance.windSpeedKph,
      'wind_degree': instance.windDegrees,
      'gust_kph': instance.windGustKph,
      'precip_mm': instance.precipitationMm,
      'chance_of_rain': instance.chanceOfRain,
      'chance_of_snow': instance.chanceOfSnow,
      'condition': instance.condition,
      'is_day': instance.isDay,
    };

WeatherCondition _$WeatherConditionFromJson(Map<String, dynamic> json) =>
    WeatherCondition(
      text: json['text'] as String?,
      icon: WeatherCondition._iconFromJson(json['icon']),
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WeatherConditionToJson(WeatherCondition instance) =>
    <String, dynamic>{
      'text': instance.text,
      'icon': instance.icon,
      'code': instance.code,
    };

DailyForecast _$DailyForecastFromJson(Map<String, dynamic> json) =>
    DailyForecast(
      timestamp: (json['date_epoch'] as num?)?.toInt(),
      dateString: json['date'] as String?,
      daySummary: json['day'] == null
          ? null
          : DaySummary.fromJson(json['day'] as Map<String, dynamic>),
      astro: json['astro'] == null
          ? null
          : Astro.fromJson(json['astro'] as Map<String, dynamic>),
      hourlyForecasts: (json['hour'] as List<dynamic>?)
          ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DailyForecastToJson(DailyForecast instance) =>
    <String, dynamic>{
      'date_epoch': instance.timestamp,
      'date': instance.dateString,
      'day': instance.daySummary,
      'astro': instance.astro,
      'hour': instance.hourlyForecasts,
    };

DaySummary _$DaySummaryFromJson(Map<String, dynamic> json) => DaySummary(
      maxTempC: (json['maxtemp_c'] as num?)?.toDouble(),
      minTempC: (json['mintemp_c'] as num?)?.toDouble(),
      avgTempC: (json['avgtemp_c'] as num?)?.toDouble(),
      maxWindKph: (json['maxwind_kph'] as num?)?.toDouble(),
      totalPrecipMm: (json['totalprecip_mm'] as num?)?.toDouble(),
      avgVisibilityKm: (json['avgvis_km'] as num?)?.toDouble(),
      avgHumidity: (json['avghumidity'] as num?)?.toDouble(),
      uvIndex: (json['uv'] as num?)?.toDouble(),
      condition: json['condition'] == null
          ? null
          : WeatherCondition.fromJson(
              json['condition'] as Map<String, dynamic>),
      dailyChanceOfRain: (json['daily_chance_of_rain'] as num?)?.toInt(),
      dailyChanceOfSnow: (json['daily_chance_of_snow'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DaySummaryToJson(DaySummary instance) =>
    <String, dynamic>{
      'maxtemp_c': instance.maxTempC,
      'mintemp_c': instance.minTempC,
      'avgtemp_c': instance.avgTempC,
      'maxwind_kph': instance.maxWindKph,
      'totalprecip_mm': instance.totalPrecipMm,
      'avgvis_km': instance.avgVisibilityKm,
      'avghumidity': instance.avgHumidity,
      'uv': instance.uvIndex,
      'condition': instance.condition,
      'daily_chance_of_rain': instance.dailyChanceOfRain,
      'daily_chance_of_snow': instance.dailyChanceOfSnow,
    };

Astro _$AstroFromJson(Map<String, dynamic> json) => Astro(
      sunrise: json['sunrise'] as String?,
      sunset: json['sunset'] as String?,
      moonrise: json['moonrise'] as String?,
      moonset: json['moonset'] as String?,
      moonPhase: json['moon_phase'] as String?,
      moonIllumination: json['moon_illumination'] as String?,
    );

Map<String, dynamic> _$AstroToJson(Astro instance) => <String, dynamic>{
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'moonrise': instance.moonrise,
      'moonset': instance.moonset,
      'moon_phase': instance.moonPhase,
      'moon_illumination': instance.moonIllumination,
    };
