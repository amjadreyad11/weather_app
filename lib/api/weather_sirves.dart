import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/main_weather.dart';

class ApiService {
  final String city;
  ApiService({required this.city});

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'b02af426a3fad0d92d3e0b32f9324cf0';

  // جلب بيانات الطقس الحالية
  Future<CityModel> getCurrentWeatherData() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=en'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CityModel.fromJson(data);
    } else {
      throw Exception('فشل في جلب البيانات من API');
    }
  }
}
