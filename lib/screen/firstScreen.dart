import 'package:flutter/material.dart';
import '../api/weather_sirves.dart';
import '../model/main_weather.dart';

import '../sharedprefrences/shared_weather.dart';
import 'favorite_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  Future<CityModel>? _newCity;
  String? _currentCityName;

  Future<void> fetchData(String city) async {
    setState(() {
      isLoading = true;
      _currentCityName = city;
      _newCity = ApiService(city: city).getCurrentWeatherData();
    });
  }

  IconData _mapIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.nightlight_round;
      case '02d':
      case '02n':
        return Icons.cloud;
      default:
        return Icons.cloud_queue;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _searchForm(),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<CityModel>(
                future: _newCity,
                builder: (context, snapshot) {
                  if (isLoading &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("حدث خطأ: ${snapshot.error}"));
                  } else if (!snapshot.hasData) {
                    return const Center(
                        child: Text("أدخل اسم المدينة لعرض الطقس"));
                  }

                  final d = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _mapIcon(d.iconCode),
                        size: 100,
                        color: Colors.orangeAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${d.temp.toStringAsFixed(0)}°C",
                        style: const TextStyle(
                            fontSize: 64, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _capitalize(d.description),
                        style: const TextStyle(
                            fontSize: 30, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 10),
                      Text("💧 الرطوبة: ${d.humidity}%"),
                      Text("🌬 الرياح: ${d.windSpeed} m/s"),
                      Text(
                          "🌅 الشروق: ${d.sunrise.hour}:${d.sunrise.minute.toString().padLeft(2, '0')}"),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.star, color: Colors.yellow),
                        label: const Text("إضافة إلى المفضلة"),
                        onPressed: () async {
                          await LocalStorageService.addFavorite(d.name);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("${d.name} أضيفت إلى المفضلة ✅")));
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchForm() {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _searchController,
              validator: (value) =>
              value == null || value.isEmpty ? 'اسم المدينة مطلوب' : null,
              decoration: InputDecoration(
                labelText: "ادخل اسم المدينة",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                suffixIcon: const Icon(Icons.location_city),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
              if (_formKey.currentState!.validate()) {
                fetchData(_searchController.text);
              }
            },
            child: isLoading
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("عرض"),
          ),
        ],
      ),
    );
  }
}
