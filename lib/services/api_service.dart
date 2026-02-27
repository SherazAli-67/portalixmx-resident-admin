import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/res/api_constants.dart';

class ApiService {

  static final ApiService _instance = ApiService._internal();
  factory ApiService() {
    return _instance;
  }
  ApiService._internal();
  final String _baseUrl = ApiConstants.baseUrl;

  Future<http.Response> postRequest({required String endpoint, required Map<String, dynamic> data, }) async {
    var url = Uri.parse(_baseUrl + endpoint);
    Map<String, String> headers =  await _getApiHeader();
    debugPrint("Post request url: $url\nData: $data\nHeaders: $headers");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    debugPrint("Post request response: ${response.body}");
    return response;
  }

  Future<http.Response?> postRequestWithToken({required String endpoint, required Map<String, dynamic> data,}) async {
    var url = Uri.parse(_baseUrl + endpoint);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("token");
    if(token != null){
      Map<String, String> headers =  await _getApiHeaderWithBearerToken(token);
      debugPrint("Post request with token url: $url\nData: $data\nHeaders: $headers");


      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      debugPrint("Post request with token response: ${response.body}");
      return response;
    }
    return null;
  }


   Future<bool> uploadComplaintWithImages({
    required String token,
    required String complaintText,
    required List<File> images,
  }) async {
    bool result = false;
    final url = Uri.parse("https://admin.portalixmx.com/api/app-api/save-complain");

    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Add complaint text
    request.fields['complaint'] = complaintText;

    // Add multiple image files with SAME key
    for (var image in images) {
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'img',
          image.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          filename: basename(image.path),
        ),
      );
    }
    // Send request
    final response = await request.send();
    // final responseBody = await response.stream.bytesToString();
    // debugPrint("Add complaint response: $responseBody");

    if(response.statusCode == 200){
      result = true;
    }

    return result;
  }

 /* Future<bool> postComplaintWithImages({
    required String endpoint,
    required String token,
    required String complaintText,
    required List<File> images,
  }) async {

    final url = Uri.parse("https://admin.portalixmx.com/api/app-api/save-complain");

    // Prepare headers with token
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    // Multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    // Add complaint text
    request.fields['complaint'] = complaintText;

    // Add multiple images
    for (var imageFile in images) {

      request.files.add(
        await http.MultipartFile.fromPath(
          'img', // use 'img' for each image field, if backend accepts multiple img entries
          imageFile.path,
          filename: imageFile.path.split('/').last,
          // contentType: mediaType,
        ),
      );
    }

    // Send request
    final response = await request.send();

    // Optional: Log response
    final respStr = await response.stream.bytesToString();
    print("Status: ${response.statusCode}");
    print("Body: $respStr");

    return true;

    *//*

    var url = Uri.parse(_baseUrl + endpoint);
    var request = http.MultipartRequest('POST', url);

    // Add authorization headers
    request.headers.addAll(await _getApiHeaderWithBearerToken(token));

    // Add the text field
    request.fields['complainttext'] = complaintText;

    // Add image files to 'img[]'
    for (int i = 0; i < images.length; i++) {
      File image = images[i];
      request.files.add(
        await http.MultipartFile.fromPath(
          'img', // Assuming your backend expects multiple files under same key: 'img'
          image.path,
        ),
      );
    }

    // Send the request
    final streamedResponse = await request.send();

    // Handle response
    final responseBody = await streamedResponse.stream.bytesToString();
    // print("Response Code: ${streamedResponse.statusCode}");
    print("Response Body: $responseBody");

    if(streamedResponse.statusCode == 200){
      return true;
    }
    return false;*//*

  }*/

  Future<http.Response?> getRequest({required String endpoint,}) async {
    var url = Uri.parse(ApiConstants.baseUrl + endpoint);
    debugPrint("Get URL: $url");

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("token");
    if(token != null){
      final headers = await _getApiHeaderWithBearerToken(token);
      final response = await http.get(
        url,
        headers: headers,
      );
      // debugPrint("GET Api $endpoint response: ${response.body}");
      return response;
    }

    return null;
  }

  Future<http.Response> getRequestWithQueryParams({required String endpoint,}) async {
    final Map<String, String> queryParams = {'isRedirect': "false",};
    String url = '${ApiConstants.baseUrl}$endpoint';
    final Uri uri = Uri.parse(url).replace(queryParameters: queryParams);

    Map<String, String> headers = await _getApiHeader();
    final http.Response response = await http.get(uri, headers: headers);

    return response;
  }

  Future<http.Response> postRequestChangeEmail({required String endpoint, required Map<String, dynamic> data}) async {
    var url = Uri.parse(ApiConstants.baseUrl + endpoint);
    debugPrint("Post url: $url");
    final headers = await _getApiHeader();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );


    debugPrint("$endpoint Api response: ${response.statusCode}");
    return response;
  }


  Future<http.Response> deleteRequest({required String endpoint,}) async {
    var url = Uri.parse(ApiConstants.baseUrl + endpoint);
    debugPrint("Delete Url: $url");

    final headers = await _getApiHeader();
    final response = await http.delete(url, headers: headers);

    debugPrint("$endpoint Api response: ${response.statusCode}");
    return response;
  }

  Future<http.Response> postRequestWithCookies({required String endpoint, required Map<String, dynamic> data}) async {
    var url = Uri.parse(ApiConstants.baseUrl + endpoint);
    debugPrint("Post with cookies Url: $url");
    final headers = await _getApiHeader();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    debugPrint("$endpoint Api response: ${response.statusCode}");
    return response;
  }

  Future<bool> updateProfile({required Map<String, dynamic> map}) async {
    bool result = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("token");
    if(token != null){

      final url = Uri.parse("https://admin.portalixmx.com/api/app-api/update-profile");
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add complaint text
      request.fields['name'] = map['name'];
      request.fields['mobile'] = map['mobile'];
      request.fields['additionalDetails'] = jsonEncode(map['additionalDetails']);
      // request.fields['emergencyContacts'] = jsonEncode(map['emergencyContacts']);

      if(map['img'] != null && map['img'].isNotEmpty){
        final mimeType = lookupMimeType(map['img']) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'img',
            map['img'],
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
            filename: basename(map['img']),
          ),
        );
      }

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("update profile api response: $responseBody");
      if(response.statusCode == 200){
        result = true;
      }
    }

    return result;
  }


  Future<Map<String, String>> _getApiHeader() async {
    return {'Content-Type': 'application/json',};
  }

  Future<Map<String, String>> _getApiHeaderWithBearerToken(String token) async {
    return { 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',};
  }
}