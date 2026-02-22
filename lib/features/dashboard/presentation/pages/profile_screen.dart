import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/user_provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splito_project/features/dashboard/data/datasource/remote/user_remote_datasource.dart';
import '../../../profile/data/datasource/profile_remote_datasource.dart';
import '../../domain/model/user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  
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
      
      final result = await _dataSource.uploadProfileImage(_selectedImage!);
      
      print("✅ Upload response: $result");
      
      if (result['success'] == true) {
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
          
          if (!imageUrl.startsWith('http')) {
            imageUrl = 'http://10.0.2.2:5000$imageUrl';
          }
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image', imageUrl);
          
          // Refresh user data to get updated profile image
          ref.refresh(userProvider);
          
          setState(() {
            _selectedImage = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Profile image updated successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          print("⚠️ No image URL in response, but upload was successful");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Image uploaded! Refresh to see changes."),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
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

  Widget _buildProfileImage(User? user) {
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 72,
        backgroundImage: FileImage(_selectedImage!),
        backgroundColor: kSurfaceElevated,
      );
    }
    
    if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
  String imageUrl = user.profileImage!;
  // If the URL is relative (starts with '/'), prepend the base URL
  if (!imageUrl.startsWith('http')) {
    imageUrl = 'http://10.0.2.2:5000$imageUrl';
  }
  return CircleAvatar(
    radius: 72,
    backgroundImage: NetworkImage(imageUrl),
    backgroundColor: kSurfaceElevated,
    onBackgroundImageError: (exception, stackTrace) {
      print("❌ Error loading network image: $exception");
      // Fallback to placeholder
      setState(() {
        // If you have a way to reset, but better to just show placeholder
      });
    },
  );
}
    
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
    final userAsync = ref.watch(userProvider);
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
                    onPressed: () => ref.refresh(userProvider),
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
                                child: userAsync.when(
                                  data: (user) => _buildProfileImage(user),
                                  loading: () => const CircleAvatar(
                                    radius: 72,
                                    backgroundColor: kSurfaceElevated,
                                    child: CircularProgressIndicator(color: kAccent),
                                  ),
                                  error: (_, __) => CircleAvatar(
                                    radius: 72,
                                    backgroundColor: kSurfaceElevated,
                                    child: Icon(Icons.error, color: kNegative, size: 40),
                                  ),
                                ),
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
                  child: userAsync.when(
                    data: (user) => _buildUserContent(user),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(
                      child: Column(
                        children: [
                          Text('Error loading profile: $e', style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(userProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserContent(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.username,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
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
                    _buildModernInfoRow(Icons.person_outline, "Username", user.username),
                    const Divider(color: kDivider, height: 32),
                    _buildModernInfoRow(Icons.email_outlined, "Email", user.email),
                    const Divider(color: kDivider, height: 32),
                    _buildModernInfoRow(
                      Icons.image_outlined,
                      "Profile photo",
                      user.profileImage != null ? "Set" : "Not set",
                      color: user.profileImage != null ? kPositive : kNegative,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
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
        if (user.profileImage != null && user.profileImage!.isNotEmpty)
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
                          Clipboard.setData(ClipboardData(text: user.profileImage!));
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
                    user.profileImage!,
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