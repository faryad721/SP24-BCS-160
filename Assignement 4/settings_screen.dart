class WeatherModel {
  final String city;
  final String country;
  final double temp;
  final double feelsLike;
  final String description;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double lat;
  final double lon;
  final int sunrise;
  final int sunset;
  final int pressure;
  final int visibility;
  final double uvIndex;

  WeatherModel({
    required this.city,
    required this.country,
    required this.temp,
    required this.feelsLike,
    required this.description,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.lat,
    required this.lon,
    required this.sunrise,
    required this.sunset,
    required this.pressure,
    required this.visibility,
    this.uvIndex = 2.0, // Default or fetch from OneCall if available
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'],
      country: json['sys']['country'],
      temp: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      description: json['weather'][0]['description'],
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      lat: json['coord']['lat'],
      lon: json['coord']['lon'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      pressure: json['main']['pressure'],
      visibility: json['visibility'],
    );
  }
}

class ForecastItem {
  final DateTime dateTime;
  final double temp;
  final String condition;

  ForecastItem({
    required this.dateTime,
    required this.temp,
    required this.condition,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
    );
  }
}
