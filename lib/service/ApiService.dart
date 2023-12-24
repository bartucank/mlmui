import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlmui/models/ReceiptHistoryDTOListResponse.dart';
import 'package:mlmui/models/ShelfDTOListResponse.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import 'package:mlmui/models/UserNamesDTOListResponse.dart';
import '../models/BookCategoryEnumDTO.dart';
import '../models/BookCategoryEnumDTOListResponse.dart';
import '../models/BookDTOListResponse.dart';
import '../models/OpenLibraryBookDetails.dart';
import 'CacheManager.dart';
import 'constants.dart';

import 'package:dio/dio.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

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
    print('${Constants.apiBaseUrl}/api/auth/login');
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
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
    if (response.statusCode == 200) {
      saveJwtToken(jsonResponse['data']['jwt']);
    }
    return jsonResponse;
  }

  Future<UserDTO> getUserDetails() async {
    final jwtToken = await getJwtToken();
    print("burada jwt gelecek mii: " + jwtToken!);
    print("burada jwt gelecek mii: ");
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/getUserDetails'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return UserDTO.fromJson(jsonResponse['data']);
  }

  Future<UserDTOListResponse> getUsersBySpecifications(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/admin/user/getUsersBySpecifications'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return UserDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<BookDTOListResponse> getBooksBySpecification(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/book/getBooksBySpecification'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    print(response.body);
    return BookDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<OpenLibraryBookDetails> getOpenLibraryBookDetails(String isbn) async {
    final jwtToken = await getJwtToken();
    print("test");
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/book/getByISBN?isbn=$isbn'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    print(response);

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    print(response.body);
    return OpenLibraryBookDetails.fromJson(jsonResponse['data']);
  }

  Future<ShelfDTOListResponse> getShelfDTOListResponse() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/shelf/getAll'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    print(response);

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    print(response.body);
    return ShelfDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<BookCategoryEnumDTOListResponse>
      getBookCategoryEnumDTOListResponse() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/book/getAllCategories'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    print(response);

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return BookCategoryEnumDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<UserNamesDTOListResponse> getUserNamesDTOListResponse() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/getUsersForBorrowPage'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    print(response);

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return UserNamesDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<String> createBook(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/book/create'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['data']['statusCode'];
  }

  Future<String> updateBook(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/book/update'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['data']['statusCode'];
  }

  Future<int> uploadImage(ImageFile imageFile) async {
    try {
      final jwtToken = await getJwtToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/api/admin/uploadImage'),
      );
      Map<String, String> headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-type": "multipart/form-data"
      };
      if (imageFile.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageFile.bytes!, // Image bytes
            filename: '${imageFile.name}.${imageFile.extension}',
          ),
        );
      } else if (imageFile.path != null) {
        File file = File(imageFile.path!);
        List<int> imageBytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes, // Image bytes
            filename: '${imageFile.name}.${imageFile.extension}',
          ),
        );
      }
      request.headers.addAll(headers);
      var res = await request.send();
      if (res.statusCode == 200) {
        var responseString = await res.stream.bytesToString();
        var jsonResponse = json.decode(responseString);
        var msgValue = int.parse(jsonResponse['data']['msg']);
        return msgValue;
      }
      return -1;
    } catch (e) {
      return -1;
      print('Error uploading image: $e');
    }
  }

  Future<Map<String, dynamic>> createReceipt(int id) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/createReceipt?imageId=$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'];
  }

  Future<Map<String, dynamic>> borrowBook(int bookid, int userId) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/admin/book/borrow?bookId=$bookid&userId=$userId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    } else if (response.statusCode == 500) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("aaaa");
      print(jsonResponse);
      return jsonResponse['data'];
    }
  }

  Future<Map<String, dynamic>> takeBackBook(int bookid) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/admin/book/takeBackBook?bookId=$bookid'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    } else if (response.statusCode == 500) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['data'];
    }
  }

  Future<ReceiptHistoryDTOListResponse> getReceiptsofUser() async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/getReceiptsofUser'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return ReceiptHistoryDTOListResponse.fromJson(jsonResponse['data']);
  }
}

class CustomException implements Exception {
  final String message;

  CustomException(this.message);
}
