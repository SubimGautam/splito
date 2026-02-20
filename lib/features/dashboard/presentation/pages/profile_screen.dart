import 'dart:convert';
import 'dart:io';
import 'dart:ui';
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

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kSurfaceElevated = Color(0xFF1F2630);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kAccentDark = Color(0xFF0891B2);
  static const Color kPositive = Color(0xFF10B981);
  static const Color kNegative = Color(0xFFEF4444);
  static const Color kDivider = Color(0xFF2A3344);

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
        radius: 72,
        backgroundImage: NetworkImage(_currentProfileImageUrl!),
        backgroundColor: kSurfaceElevated,
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
        radius: 72,
        backgroundImage: FileImage(_selectedImage!),
        backgroundColor: kSurfaceElevated,
      );
    }
    
    // Default: Show placeholder
    print("🖼️ Displaying placeholder");
    return CircleAvatar(
      radius: 72,
      backgroundColor: kSurfaceElevated,
      child: Icon(
        Icons.person,
        size: 80,
        color: kTextSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: kSurface,
          foregroundColor: kTextPrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kAccent),
              SizedBox(height: 20),
              Text(
                "Loading profile...",
                style: TextStyle(
                  fontSize: 16,
                  color: kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBackground, kSurface.withOpacity(0.92)],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                backgroundColor: kSurface,
                actions: [
                  IconButton(
                    onPressed: _loadUserProfile,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text("Profile"),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              kBackground.withOpacity(0.85),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kAccent.withOpacity(0.4), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kAccent.withOpacity(0.25),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: _buildProfileImage(),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: kSurface, width: 3),
                                  ),
                                  child: _isUploading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName ?? "Your Name",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail ?? "email@domain.com",
                        style: TextStyle(
                          fontSize: 16,
                          color: kTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: kSurfaceElevated.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _buildModernInfoRow(Icons.person_outline, "Full name", _userName ?? "—"),
                                  const Divider(color: kDivider, height: 32),
                                  _buildModernInfoRow(Icons.email_outlined, "Email", _userEmail ?? "—"),
                                  const Divider(color: kDivider, height: 32),
                                  _buildModernInfoRow(
                                    Icons.image_outlined,
                                    "Profile photo",
                                    _currentProfileImageUrl != null ? "Set" : "Not set",
                                    color: _currentProfileImageUrl != null ? kPositive : kNegative,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Tips",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        "Tap your photo to change it",
                        "Clear cache if image doesn't update",
                        "Use high quality images for best result"
                      ].map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle, size: 16, color: kAccent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(tip, style: TextStyle(color: kTextSecondary)),
                                ),
                              ],
                            ),
                          )),
                      if (_isUploading)
                        Card(
                          color: kSurfaceElevated,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Uploading image...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: kAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  backgroundColor: kDivider,
                                  valueColor: AlwaysStoppedAnimation<Color>(kAccent),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Please wait while your image is being uploaded",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kTextSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty)
                        Card(
                          color: kDivider.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info, size: 16, color: kTextSecondary),
                                    const SizedBox(width: 5),
                                    const Text(
                                      "Debug Info:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: kTextSecondary,
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
                                    color: kTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 22, color: kAccent),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: kTextSecondary, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: color ?? kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}