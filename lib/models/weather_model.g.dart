// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      conditionCode: (json['code'] as num?)?.toInt(),
      conditionText: json['text'] as String?,
      iconUrl: json['icon'] as String?,
      temperature: (json['temp_c'] as num?)?.toDouble(),
      feelsLike: (json['feelslike_c'] as num?)?.toDouble(),
      tempMax: (json['maxtemp_c'] as num?)?.toDouble(),
      tempMin: (json['mintemp_c'] as num?)?.toDouble(),
      pressure: (json['pressure_mb'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      visibilityKm: (json['vis_km'] as num?)?.toDouble(),
      windSpeedKph: (json['wind_kph'] as num?)?.toDouble(),
      windDegrees: (json['wind_degree'] as num?)?.toInt(),
      clouds: (json['cloud'] as num?)?.toInt(),
      precipitationMm: (json['precip_mm'] as num?)?.toDouble(),
      sunriseTime: json['sunrise_time'] as String?,
      sunsetTime: json['sunset_time'] as String?,
      cityName: json['name'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      timezoneId: json['tz_id'] as String?,
      lastUpdatedEpoch: (json['last_updated_epoch'] as num?)?.toInt(),
      isDay: (json['is_day'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'code': instance.conditionCode,
      'text': instance.conditionText,
      'icon': instance.iconUrl,
      'temp_c': instance.temperature,
      'feelslike_c': instance.feelsLike,
      'maxtemp_c': instance.tempMax,
      'mintemp_c': instance.tempMin,
      'pressure_mb': instance.pressure,
      'humidity': instance.humidity,
      'vis_km': instance.visibilityKm,
      'wind_kph': instance.windSpeedKph,
      'wind_degree': instance.windDegrees,
      'cloud': instance.clouds,
      'precip_mm': instance.precipitationMm,
      'sunrise_time': instance.sunriseTime,
      'sunset_time': instance.sunsetTime,
      'name': instance.cityName,
      'lat': instance.lat,
      'lon': instance.lon,
      'tz_id': instance.timezoneId,
      'last_updated_epoch': instance.lastUpdatedEpoch,
      'is_day': instance.isDay,
    };
