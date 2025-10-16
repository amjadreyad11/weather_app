class CityModel {
  final String name;
  final double temp;
  final String description;
  final double windSpeed;
  final String iconCode;
  final int humidity;
  final DateTime sunrise;

  CityModel({
    required this.name,
    required this.temp,
    required this.description,
    required this.windSpeed,
    required this.iconCode,
    required this.humidity,
    required this.sunrise,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json["name"],
      temp: (json['main']['temp'] as num).toDouble(),
      description: (json['weather'][0]['description'] as String),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      iconCode: (json['weather'][0]['icon'] as String),
      humidity: json['main']['humidity'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] as int) * 1000,
        isUtc: true,
      ).toLocal(),
    );
  }
}
