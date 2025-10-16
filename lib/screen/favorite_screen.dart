import 'package:flutter/material.dart';
import '../api/weather_sirves.dart';
import '../model/main_weather.dart';
import '../sharedprefrences/shared_weather.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<String>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = LocalStorageService.getFavorites();
  }

  Future<void> _refresh() async {
    setState(() {
      _favorites = LocalStorageService.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المدن المفضلة ❤️"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد مدن مفضلة بعد"));
          }

          final cities = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return FutureBuilder<CityModel>(
                  future: ApiService(city: city).getCurrentWeatherData(),
                  builder: (context, weatherSnap) {
                    if (!weatherSnap.hasData) {
                      return const ListTile(title: Text("..."));
                    }
                    final d = weatherSnap.data!;
                    return ListTile(
                      leading: const Icon(Icons.location_city, color: Colors.blue),
                      title: Text("${d.name} - ${d.temp.toStringAsFixed(0)}°C"),
                      subtitle: Text(d.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await LocalStorageService.removeFavorite(city);
                          _refresh();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
