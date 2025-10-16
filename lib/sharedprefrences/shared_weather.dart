import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyFavorites = 'favorite_cities';

  // إضافة مدينة إلى المفضلة
  static Future<void> addFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_keyFavorites) ?? [];
    if (!favorites.contains(city)) {
      favorites.add(city);
      await prefs.setStringList(_keyFavorites, favorites);
    }
  }

  // حذف مدينة
  static Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_keyFavorites) ?? [];
    favorites.remove(city);
    await prefs.setStringList(_keyFavorites, favorites);
  }

  // قراءة المفضلات
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }
}
