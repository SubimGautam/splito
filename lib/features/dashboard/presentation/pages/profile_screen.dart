import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/user_provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _debugImageUrl; // For debugging

  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource();

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kSurfaceElevated = Color(0xFF1F2630);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
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
      print("=" * 50);
      print("📤 UPLOADING IMAGE");
      print("=" * 50);
      
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
          print("🖼️ Raw image URL from upload: $imageUrl");
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image', imageUrl);

          // Invalidate user provider to force refetch
          ref.invalidate(userProvider);

          setState(() {
            _selectedImage = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Profile image updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? "Upload failed");
      }
    } catch (e) {
      print("❌ Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _getAccessibleImageUrl(String? url) {
    print("=" * 50);
    print("🔍 IMAGE URL TRANSFORMATION");
    print("=" * 50);
    print("📥 Original URL from backend: $url");
    
    if (url == null || url.isEmpty) {
      print("⚠️ URL is null or empty");
      return '';
    }
    
    String imageUrl = url;
    
    // Handle localhost replacement for Android emulator
    if (imageUrl.contains('localhost')) {
  imageUrl = imageUrl.replaceFirst('localhost', '192.168.1.115');
} else if (!imageUrl.startsWith('http')) {
  imageUrl = 'http://192.168.1.115:5000$imageUrl';
}
    
    // Add cache-busting timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final separator = imageUrl.contains('?') ? '&' : '?';
    imageUrl = '$imageUrl${separator}t=$timestamp';
    print("✅ Final image URL with cache buster: $imageUrl");
    print("=" * 50);
    
    return imageUrl;
  }

  Widget _buildProfileImage(User? user) {
    const double size = 144; // 2 * 72

    print("=" * 50);
    print("🖼️ BUILDING PROFILE IMAGE");
    print("=" * 50);
    
    // Priority 1: Selected image (before upload)
    if (_selectedImage != null) {
      print("📸 Using selected local image");
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("❌ Error loading selected image: $error");
            return _buildPlaceholder();
          },
        ),
      );
    }

    // Priority 2: User's profile image from provider
    if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
  print("🖼️ Loading image from: ${user.profileImage}");
  return ClipOval(
    child: Image.network(
      user.profileImage!,
      width: 144,
      height: 144,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder(showProgress: true);
      },
      errorBuilder: (context, error, stackTrace) {
        print("❌ Image load error: $error");
        return _buildPlaceholder();
      },
    ),
  );
}

    print("👤 No profile image, showing placeholder");
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({bool showProgress = false}) {
    return Container(
      width: 144,
      height: 144,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1F2630),
      ),
      child: showProgress
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22D3EE)))
          : const Icon(Icons.person, size: 80, color: Color(0xFF94A3B8)),
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
                    onPressed: () {
                      print("🔄 Manual refresh triggered");
                      ref.invalidate(userProvider);
                    },
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
                              userAsync.when(
                                data: (user) => _buildProfileImage(user),
                                loading: () {
                                  print("⏳ User data loading...");
                                  return _buildPlaceholder(showProgress: true);
                                },
                                error: (error, stackTrace) {
                                  print("❌ Error loading user data: $error");
                                  return _buildPlaceholder();
                                },
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
                            onPressed: () => ref.invalidate(userProvider),
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