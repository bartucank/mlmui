import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import '../models/BookDTOListResponse.dart';
import 'CacheManager.dart';
import 'constants.dart';
class ApiService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> getJwtToken() async {
    try {
      final jwtToken = await storage.read(key: 'jwt_token');
      return jwtToken;
    } catch (error) {
      return "NOT_FOUND";
    }

  }

  Future<void> saveJwtToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<Map<String, dynamic>> loginRequest(dynamic body) async {
    final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if(response.statusCode == 200){
      saveJwtToken(jsonResponse['data']['jwt']);

    }
    print(jsonResponse);
    return jsonResponse;
  }

  Future<Map<String, dynamic>> verifyRequest(String code) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/auth/verify?code=$code'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  Future<Map<String, dynamic>> registerRequest(dynamic body) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if(response.statusCode == 200){
      saveJwtToken(jsonResponse['data']['jwt']);

    }
    return jsonResponse;
  }
  Future<UserDTO> getUserDetails() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/getUserDetails'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return UserDTO.fromJson(jsonResponse['data']);
  }


  Future<UserDTOListResponse> getUsersBySpecifications(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/user/getUsersBySpecifications'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return UserDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<BookDTOListResponse> getBooksBySpecification(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/book/getBooksBySpecification'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    print(response.body);
    return BookDTOListResponse.fromJson(jsonResponse['data']);
  }
}

class CustomException implements Exception {
  final String message;

  CustomException(this.message);
}