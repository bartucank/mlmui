import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mlmui/models/BookReviewDTO.dart';
import 'package:mlmui/models/CourseDTO.dart';
import 'package:mlmui/models/DepartmentDTOListResponse.dart';
import 'package:mlmui/models/CourseMaterialDTO.dart';
import 'package:mlmui/models/ReceiptHistoryDTOListResponse.dart';
import 'package:mlmui/models/RoomDTOListResponse.dart';
import 'package:mlmui/models/CourseDTOListResponse.dart';
import 'package:mlmui/models/ShelfDTOListResponse.dart';
import 'package:mlmui/models/StatisticsDTOListResponse.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import 'package:mlmui/models/UserNamesDTOListResponse.dart';
import 'package:mlmui/models/StatisticsDTO.dart';
import 'package:path/path.dart';
import '../models/BookCategoryEnumDTOListResponse.dart';
import '../models/BookDTO.dart';
import '../models/BookDTOListResponse.dart';
import '../models/EbookDTO.dart';
import '../models/MyBooksDTOListResponse.dart';
import '../models/OpenLibraryBookDetails.dart';
import '../models/QueueDetailDTO.dart';
import '../models/RoomSlotDTOListResponse.dart';
import 'constants.dart';

import 'package:multi_image_picker_view/multi_image_picker_view.dart';

class ApiService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
    if (response.statusCode == 200) {
      await saveJwtToken(jsonResponse['data']['jwt']);
    }
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
      await saveJwtToken(jsonResponse['data']['jwt']);
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
    return BookDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<BookDTOListResponse> getBookRecommendationBasedOnUser(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/book/getBookRecommendation'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: "{}",
    );
    print(response.statusCode);
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    print(response.body);
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return BookDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<BookDTOListResponse> getBookRecommendationBasedOnBook(int bookId) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/book/getBookRecommendation?bookId=$bookId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: "{}",
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    print(response.body);
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return BookDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<OpenLibraryBookDetails> getOpenLibraryBookDetails(String isbn) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/book/getByISBN?isbn=$isbn'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
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

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

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
    }
  }


  Future<String> uploadExcelForBook(File file) async {
    try {
      final jwtToken = await getJwtToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/api/admin/uploadExcel'),
      );
      Map<String, String> headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-type": "multipart/form-data"
      };

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.readAsBytesSync(),
          filename: 'excel.xlsx',
        ),
      );
      request.headers.addAll(headers);
      var res = await request.send();
      var responseString = await res.stream.bytesToString();
      var jsonResponse = json.decode(responseString);
      print(jsonResponse);
      if (res.statusCode == 200) {
        print("will be return:"+jsonResponse['data']['msg']);
        return jsonResponse['data']['msg'];
      }
      return "-1";
    } catch (e) {
      return "-1";
    }
  }
  Future<String> uploadExcelForStudent(File file) async {
    try {
      final jwtToken = await getJwtToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/api/admin/uploadExcel'),
      );
      Map<String, String> headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-type": "multipart/form-data"
      };

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.readAsBytesSync(),
          filename: 'excel.xlsx',
        ),
      );
      request.headers.addAll(headers);
      var res = await request.send();
      var responseString = await res.stream.bytesToString();
      var jsonResponse = json.decode(responseString);
      print(jsonResponse);
      if (res.statusCode == 200) {
        print("will be return:"+jsonResponse['data']['msg']);
        return jsonResponse['data']['msg'];
      }
      return "-1";
    } catch (e) {
      return "-1";
    }
  }

  Future<String> uploadExcelForBookForWeb(Uint8List file) async {
    try {
      final jwtToken = await getJwtToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/api/admin/uploadExcel'),
      );
      Map<String, String> headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-type": "multipart/form-data"
      };

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file,
          filename: 'excel.xlsx',
        ),
      );
      request.headers.addAll(headers);
      var res = await request.send();
      var responseString = await res.stream.bytesToString();
      var jsonResponse = json.decode(responseString);
      print(jsonResponse);
      if (res.statusCode == 200) {
        print("will be return:"+jsonResponse['data']['msg']);
        return jsonResponse['data']['msg'];
      }
      return "-1";
    } catch (e) {
      return "-1";
    }
  }

  Future<int> uploadImageByBase64(String base64) async {
    try {

      Map<String, dynamic> request = {
        "base64":base64,
      };
      final jwtToken = await getJwtToken();
      final res = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/admin/uploadImageByBase64'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request),
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(res.body);
        var msgValue = int.parse(jsonResponse['data']['msg']);
        return msgValue;
      }
      return -1;
    } catch (e) {
      return -1;
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
  Future<Map<String, dynamic>> getStatusOfBook(int bookId) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/getQueueStatusBasedOnBook?id=$bookId'),
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
  Future<Map<String, dynamic>> enqueue(int bookId) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/enqueue?id=$bookId'),
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
    final response = await http.get(
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
  
  Future<MyBooksDTOListResponse> getMyBooks() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/myBooks'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return MyBooksDTOListResponse.fromJson(jsonResponse['data']);
  }
      
  Future<StatisticsDTO> getStatistics() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/getStatistics'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return StatisticsDTO.fromJson(jsonResponse['data']);
  }


  Future<StatisticsDTOListResponse> getStatisticsForChart() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/getStatisticsForChart'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return StatisticsDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<QueueDetailDTO> getQueueStatusBasedOnBookForLibrarian(int bookId) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/getQueueStatusBasedOnBookForLibrarian?id=$bookId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }

    if (response.statusCode == 500) {

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      throw CustomException(jsonResponse['message']);
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return QueueDetailDTO.fromJson(jsonResponse['data']);
  }

  
    Future<String> createRoom(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/createRoom'),
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
  
  
 
  Future<RoomDTOListResponse> getrooms() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getRooms'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return RoomDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<RoomSlotDTOListResponse> getroomslots(int id) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getRoomSlotsByRoomId?id=$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return RoomSlotDTOListResponse.fromJson(jsonResponse['data']);
  }


  Future<Map<String, dynamic>> makeReservation(int id) async {
    print(id);
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/makeReservation?roomSlotId=$id'),

      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },

    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

  
    return jsonResponse;

  }

  Future<String> updateRoleOfUser(int userId, String role) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/updateRoleOfUser?role=$role&userId=$userId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode('{}'),
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['data']['statusCode'];
  }

  Future<String> changePass(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/changePassword'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      return "-1";
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    print("json:"+jsonResponse.toString());
    if(response.statusCode == 200){
      await saveJwtToken(jsonResponse['data']['jwt']);
      return "ok";
    }
    return "-1";
  }

  Future<ReceiptHistoryDTOListResponse> getReceiptsByStatus(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/admin/getReceiptsByStatus'),
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
    return ReceiptHistoryDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<ReceiptHistoryDTOListResponse> getReceipts() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getReceipts'),
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

  Future<ReceiptHistoryDTOListResponse> getReceiptByUserID(int id) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getReceiptByUser?userId=$id'),
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

  Future<ReceiptHistoryDTOListResponse> getReceiptsHashMap() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getReceiptsHashMap'),
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

  Future<String> approveReceipt(double balance, int receiptId) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/approveReceipt?balance=$balance&receiptId=$receiptId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode('{}'),
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['data']['statusCode'];
  }

  Future<String> rejectReceipt(int receiptId) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/rejectReceipt?receiptId=$receiptId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode('{}'),
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['data']['statusCode'];
  }


  Future<String> makeReview(dynamic body) async{
    final jwtToken = await getJwtToken();
    final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/user/addReview'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body)
    );
    print("Yolladik gibi");
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<List<BookReviewDTO>> getBookReviewsByBookId(int bookId)async{
    final jwtToken = await getJwtToken();
    final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/api/user/book/getBookReviewsByBookId?id=$bookId'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        }
    );

    print("Response Body: ${response.body}");

    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }

    if(response.statusCode == 500){
      Map<String,dynamic> jsonResponse = jsonDecode(response.body);
      throw CustomException(jsonResponse['message']);
    }

    List<dynamic> data = jsonDecode(response.body)['data'];
    return data.map<BookReviewDTO>((json) => BookReviewDTO.fromJson(json)).toList();
  }

  Future<String> addToFavorite(int bookid) async{
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/favorite/addToFavorite?bookId=$bookid'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },

    );
    print("Yolladik gibi");
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<String> addEbook(int bookId, dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/admin/ebook/addEbook?bookId=$bookId'),
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

  Future<EbookDTO> getEbook(int id) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/ebook/getEbook?id=$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return EbookDTO.fromJson(jsonResponse['data']);
  }
  Future<CourseMaterialDTO> getCourseMaterialById(int id) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/course/getCourseMaterialById?id=$id'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return CourseMaterialDTO.fromJson(jsonResponse['data']);
  }


  Future<List<BookDTO>> getFavoriteBooks() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/favorite/getFavorites'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    } else if (response.statusCode == 500) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      throw CustomException(jsonResponse['message']);
    } else if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('data') && jsonResponse['data'].containsKey('bookDTOList')) {
        List<dynamic> books = jsonResponse['data']['bookDTOList'];
        return books.map<BookDTO>((json) => BookDTO.fromJson(json)).toList();
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load favorite books with status code: ${response.statusCode}');
    }
  }

  Future<String> removeFavorite(int bookid) async{
    final jwtToken = await getJwtToken();
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/user/favorite/removeFavorite?bookId=$bookid'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },

    );
    print("Yolladik gibi");
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<bool> isFavorite(int bookid) async{
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/favorite/isFavorited?bookId=$bookid'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },

    );

    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    else if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      bool isFavorited = jsonResponse['data'];
      return isFavorited;
    } else {
      return false;
    }
  }

  Future<DepartmentDTOListResponse>  getDepartmentDTOList() async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/auth/getDeps'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return DepartmentDTOListResponse.fromJson(jsonResponse['data']);
  }

  Future<String> deleteEbook(int bookid) async{
    final jwtToken = await getJwtToken();
    print(bookid);
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/ebook/deleteEbook?bookId=$bookid'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },

    );
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    return jsonResponse['data']['statusCode'];
  }
  Future<int> uploadEbook(ImageFile imageFile, int bookid) async {
    try {
      final jwtToken = await getJwtToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/api/admin/ebook/addEbook?bookId=$bookid'),
      );
      Map<String, String> headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-type": "multipart/form-data"
      };
      if (imageFile.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageFile.bytes!, // Image bytes
            filename: '${imageFile.name}.${imageFile.extension}',
          ),
        );
      } else if (imageFile.path != null) {
        File file = File(imageFile.path!);
        List<int> imageBytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes, // Image bytes
            filename: '${imageFile.name}.${imageFile.extension}',
          ),
        );
      }
      request.headers.addAll(headers);
      var res = await request.send();
      if (res.statusCode == 200) {
        return 1;
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }


  Future<bool> checkReservationIsExists() async{
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/user/checkNowReservationExists'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },

    );

    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    else if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      bool isFavorited = jsonResponse['data'];
      return isFavorited;
    } else {
      return false;
    }
  }

  Future<bool> approveReservation(String key) async{
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/user/approveReservation?key=$key'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: "{}"

    );

    print("resp body:"+response.statusCode.toString());
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    else if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      bool res = jsonResponse['data'];
      return res;
    } else {
      return false;
    }
  }

  Future<String> createCourse(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/create'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
      body: jsonEncode(body),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }


  Future<CourseDTOListResponse> getCourseForLecturer() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/lecturer/course/getCoursesForLecturer'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return CourseDTOListResponse.fromJson(jsonResponse['data']);
    } else {
      throw CustomException("Error fetching courses: Status code ${response.statusCode}");
    }
  }

  Future<CourseDTOListResponse> getCourseForUser() async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse(
          '${Constants.apiBaseUrl}/api/user/course/getCoursesForUser'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return CourseDTOListResponse.fromJson(jsonResponse['data']);
    } else {
      throw CustomException("Error fetching courses: Status code ${response.statusCode}");
    }
  }

  Future<String> bulkAddStudentToCourse(int courseId) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/bulkAddStudentToCourse?courseId=$courseId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );

    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<String> bulkRemoveStudentFromCourse(int courseId) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/bulkRemoveStudentFromCourse?courseId=$courseId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );

    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<String> inviteStudent(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/invite'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
      body: jsonEncode(body),
    );

    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    print(response.body);
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if(response.statusCode == 500 && jsonResponse['message'] != null){
      return jsonResponse['message'];
    }
    return jsonResponse['data']['statusCode'];
  }

  Future<String> removeStudentFromCourse(int courseId, int courseStudentId) async {
    final jwtToken = await getJwtToken();
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/removeStudentFromCourse?courseId=$courseId&courseStudentId=$courseStudentId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  String getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'epub':
        return 'application/epub+zip';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'html':
        return 'text/html';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String> uploadCourseMaterial(String name, int courseId, String filePath) async {
    try {
      final jwtToken = await getJwtToken();
      var uri = Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/uploadCourseMaterial');
      var request = http.MultipartRequest('POST', uri);


      print("Name before request: '$name'");
      request.fields['name'] = name;
      request.fields['courseId'] = courseId.toString();

      File file = File(filePath);
      request.files.add(
          http.MultipartFile(
              'file',
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: basename(file.path),
              contentType: MediaType.parse(getMimeType(basename(file.path).split('.').last))
          )
      );

      Map<String, String> headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-type": "multipart/form-data"
      };

      request.headers.addAll(headers);
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseString);
      print(jsonResponse);

      if (response.statusCode == 200) {
        print(response.statusCode);
        return jsonResponse['data']['statusCode'];
      } else {
        print("Failed to upload material. Status code: ${response.statusCode}. Response: $responseString");
        return "-1";
      }
    } catch (e) {
      print("Error uploading material: $e");
      return "-1";
    }
  }
  Future<String> uploadCourseStudentExcel( int courseId, String filePath) async {
    try {
      final jwtToken = await getJwtToken();
      var uri = Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/bulkAddStudentToCourse');
      var request = http.MultipartRequest('POST', uri);
      request.fields['courseId'] = courseId.toString();
      File file = File(filePath);
      request.files.add(
          http.MultipartFile(
              'file',
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: basename(file.path),
              contentType: MediaType.parse(getMimeType(basename(file.path).split('.').last))
          )
      );

      Map<String, String> headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-type": "multipart/form-data"
      };

      request.headers.addAll(headers);
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseString);
      print(jsonResponse);

      if (response.statusCode == 200) {
        print(response.statusCode);
        return jsonResponse['data']['statusCode'];
      } else {
        return "-1";
      }
    } catch (e) {
      return "-1";
    }
  }



  Future<String> deleteCourseMaterial(int materialId) async {
    final jwtToken = await getJwtToken();
    print(materialId);
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/deleteCourseMaterial?materialId=$materialId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );

    print(response.body);
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<String> deleteCourse(int courseId) async {
    final jwtToken = await getJwtToken();
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/deleteCourse?courseId=$courseId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );

    print(response.body);
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<String> finishCourseTerm(int courseId) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants
          .apiBaseUrl}/api/lecturer/course/finishCourseTerm?courseId=$courseId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<CourseDTO> getCourseByIdForLecturer(int courseId) async {
    final jwtToken = await getJwtToken();
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/lecturer/course/getCourseByIdForLecturer?id=$courseId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }

    print(response.body);
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return CourseDTO.fromJson(jsonResponse['data']);
  }
  /*print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');*/
  Future<String> deleteShelf(int oldShelfId) async {
    final jwtToken = await getJwtToken();
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/deleteShelf?oldShelfId=$oldShelfId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }


  Future<String> moveAndDeleteShelf(int newShelfId, int oldShelfId) async {
    final jwtToken = await getJwtToken();
    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/admin/deleteShelf?newShelfId=$newShelfId&oldShelfId=$oldShelfId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if(response.statusCode == 401){
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }


  Future<String> moveShelf(int newShelfId, int oldShelfId) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants
          .apiBaseUrl}/api/admin/moveShelf?newShelfId=$newShelfId&oldShelfId=$oldShelfId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }


  Future<String> createShelf(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.post(
      Uri.parse('${Constants
          .apiBaseUrl}/api/admin/shelf/create'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
      body: jsonEncode(body),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }

  Future<String> updateShelf(dynamic body) async {
    final jwtToken = await getJwtToken();
    final response = await http.put(
      Uri.parse('${Constants
          .apiBaseUrl}/api/admin/shelf/update'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',

      },
      body: jsonEncode(body),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 401) {
      throw CustomException("NEED_LOGIN");
    }
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse['data']['statusCode'];
  }


  Future<String> startForgotPasswordProcess(Map<String, dynamic> body) async {
    try {
      final jwtToken = await getJwtToken();
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/auth/startForgotPasswordProcess'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 401) {
        throw CustomException("USER_NOT_FOUND_OR_INVALID_REQUEST");
      }
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      return jsonResponse['data']['statusCode'];
    } catch (e) {
      print('Error: $e');
      return "-1";
    }
  }

  Future<bool> checkCodeForResetPassword(String code) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/auth/checkCodeForResetPassword?code=$code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode("{}"),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return jsonResponse['data'];
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> completeCodeForResetPassword(Map<String, dynamic> body) async {
    try {
      final jwtToken = await getJwtToken();
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/auth/completeCodeForResetPassword'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Unexpected error!'};
      }
    } catch (e) {
      print('Error: $e');
      return {'error': e.toString()};
    }
  }



}

class CustomException implements Exception {
  final String message;

  CustomException(this.message);
}
