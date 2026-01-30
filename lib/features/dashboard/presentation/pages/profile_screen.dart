import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../profile/data/datasource/profile_remote_datasource.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  bool _isLoading = true;
  String? _currentProfileImageUrl;
  String? _userName;
  String? _userEmail;
  
  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data from SharedPreferences or API
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get user data from different possible keys
      final userName = prefs.getString('user_name') ?? 
                      prefs.getString('username') ?? 
                      'User';
      final userEmail = prefs.getString('user_email') ?? 
                       prefs.getString('email') ?? 
                       'user@example.com';
      final profileImage = prefs.getString('profile_image');
      
      setState(() {
        _userName = userName;
        _userEmail = userEmail;
        _currentProfileImageUrl = profileImage;
      });
      
      print("👤 Loaded user profile:");
      print("   - Name: $_userName");
      print("   - Email: $_userEmail");
      print("   - Profile Image: $_currentProfileImageUrl");
      
    } catch (e) {
      print("❌ Error loading profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _isUploading = true;
    });

    try {
      print("🖼️ Starting image upload...");
      print("📁 File path: ${image.path}");
      
      // Call the upload method
      final result = await _dataSource.uploadProfileImage(_selectedImage!);
      
      print("✅ Upload response: $result");
      
      // Check if upload was successful
      if (result['success'] == true) {
        // Extract image URL from response - handle different possible response structures
        dynamic data = result['data'];
        String? imageUrl;
        
        if (data is Map) {
          imageUrl = data['profileImage'] ?? 
                    data['fullUrl'] ?? 
                    data['imageUrl'] ?? 
                    data['url'];
        }
        
        if (imageUrl != null) {
          print("🖼️ Upload successful! Image URL: $imageUrl");
          
          // Ensure URL is complete (add base URL if needed)
          if (!imageUrl.startsWith('http')) {
            imageUrl = 'http://10.0.2.2:5000$imageUrl';
          }
          
          // Save the image URL to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image', imageUrl);
          
          // Also save user info if available in response
          if (data is Map && data['user'] != null) {
            final userData = data['user'];
            if (userData['username'] != null) {
              await prefs.setString('username', userData['username']);
            }
            if (userData['email'] != null) {
              await prefs.setString('email', userData['email']);
            }
          }
          
          // Update the UI
          setState(() {
            _currentProfileImageUrl = imageUrl;
            // Clear the selected image so we show the uploaded one
            _selectedImage = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✅ Profile image updated successfully!"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          print("🎉 Profile image updated in UI");
        } else {
          print("⚠️ No image URL in response, but upload was successful");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✅ Image uploaded! Refresh to see changes."),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        final errorMessage = result['message'] ?? 'Upload failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("❌ Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Upload failed: ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Build image widget - shows uploaded image if available, otherwise selected image
  Widget _buildProfileImage() {
    // First priority: Show uploaded image from backend
    if (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty) {
      print("🖼️ Displaying uploaded image: $_currentProfileImageUrl");
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(_currentProfileImageUrl!),
        backgroundColor: Colors.grey[200],
        onBackgroundImageError: (exception, stackTrace) {
          print("❌ Error loading network image: $exception");
          setState(() {
            _currentProfileImageUrl = null;
          });
        },
      );
    }
    
    // Second priority: Show locally selected image (before upload)
    if (_selectedImage != null) {
      print("🖼️ Displaying selected local image");
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_selectedImage!),
        backgroundColor: Colors.grey[200],
      );
    }
    
    // Default: Show placeholder
    print("🖼️ Displaying placeholder");
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.blue[100],
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.blue[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Loading profile...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: _loadUserProfile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Profile Image with Upload Button
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Profile Image
                  _buildProfileImage(),
                  
                  // Upload Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isUploading ? null : _pickAndUploadImage,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                      tooltip: 'Upload Profile Image',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // User Info
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "User Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      _buildInfoRow("Name", _userName ?? "Not set"),
                      const Divider(height: 20),
                      _buildInfoRow("Email", _userEmail ?? "Not set"),
                      const Divider(height: 20),
                      _buildInfoRow(
                        "Profile Image Status",
                        _currentProfileImageUrl != null 
                            ? "✅ Uploaded" 
                            : "❌ Not uploaded",
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Upload Status
              if (_isUploading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Uploading image...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Please wait while your image is being uploaded",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Debug Info (only in debug mode)
              if (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty)
                Card(
                  color: Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            const Text(
                              "Debug Info:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _currentProfileImageUrl!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("URL copied to clipboard"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        SelectableText(
                          _currentProfileImageUrl!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Tips Section
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            "Tips:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTip("If image doesn't appear, tap refresh button"),
                      _buildTip("Make sure you have stable internet connection"),
                      _buildTip("Image will be saved permanently to your profile"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: value.contains("✅") 
                  ? Colors.green 
                  : value.contains("❌") 
                    ? Colors.red 
                    : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}