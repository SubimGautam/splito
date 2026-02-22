import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRemoteDataSource {
  static const String baseUrl = "http://10.0.2.2:5000";

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    print("=" * 50);
    print("📤 STARTING IMAGE UPLOAD");
    print("=" * 50);
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      throw Exception("Token not found. Please login again.");
    }

    // Fix the endpoint to match your backend
    final uri = Uri.parse("$baseUrl/api/users/upload-profile-image");
    print("🌐 Upload URL: $uri");

    final request = http.MultipartRequest("POST", uri); // Change to POST

    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";
    print("📋 Headers added");

    // Add file
    try {
      print("📎 Adding file to request...");
      print("📁 File path: ${imageFile.path}");
      print("📁 File name: ${imageFile.path.split('/').last}");
      
      request.files.add(
        await http.MultipartFile.fromPath(
          "image", // This should match the field name expected by multer (you used 'image' in your backend)
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );
      print("✅ File added to request");
    } catch (e) {
      print("❌ Error adding file: $e");
      throw Exception("Failed to prepare image: $e");
    }

    print("🚀 Sending request...");
    
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("📥 Response received");
      print("📥 Status Code: ${response.statusCode}");
      print("📥 Content-Type: ${response.headers['content-type']}");
      print("📥 Body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}");
      
      // Check if response is HTML (error page)
      if (response.headers['content-type']?.contains('text/html') == true) {
        print("❌ Server returned HTML error page instead of JSON");
        print("Full HTML response:");
        print(response.body);
        throw Exception("Server error: Please check backend logs");
      }
      
      // Try to parse as JSON
      try {
        final responseData = jsonDecode(response.body);
        
        if (response.statusCode == 200) {
          if (responseData['success'] == true) {
            print("✅ Upload successful!");
            return responseData;
          } else {
            print("❌ API returned success=false");
            throw Exception(responseData['message'] ?? "Upload failed");
          }
        } else {
          print("❌ Upload failed with status: ${response.statusCode}");
          throw Exception(responseData['message'] ?? "Upload failed: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ Failed to parse response as JSON: $e");
        print("Raw response: ${response.body}");
        throw Exception("Invalid server response");
      }
    } catch (e) {
      print("🔥 Network error: $e");
      throw Exception("Upload failed: $e");
    } finally {
      print("=" * 50);
      print("📤 IMAGE UPLOAD PROCESS COMPLETED");
      print("=" * 50);
    }
  }
}