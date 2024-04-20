import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UserDTO.dart';
import 'dart:convert';

class CacheManager {
  static Future<void> saveImageDataToCache(String imageId, String base64Data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(imageId, base64Data);
  }

  static Future<String?> getImageDataFromCache(String imageId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(imageId);
  }
  static Future<void> saveUserDTOToCache(UserDTO dto) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userdto", json.encode(dto.toJson()));
  }

  static Future<UserDTO?> getUserDTOFromCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString("userdto");
    if (jsonStr != null) {
      Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return UserDTO.fromJson(jsonMap);
    } else {
      return null;
    }
  }
  static Future<void> logout() async {

    // final FlutterSecureStorage storage = FlutterSecureStorage();
    // await storage.delete(key: "jwt_token");
    // await storage.deleteAll();
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.remove("userdto");
    // await prefs.clear();
  }
}
