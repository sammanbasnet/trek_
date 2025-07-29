import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false;
  String? _uploadedImage;

  Future<void> _pickAndUploadImage(String userId, String token) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() { _isUploading = true; });
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(pickedFile.path, filename: pickedFile.name),
      });
      final response = await dio.post(
        'http://10.0.2.2:3000/api/v1/customers/uploadImage',
        data: formData,
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final updatedUser = response.data['data'];
        setState(() { _uploadedImage = updatedUser['image']; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated!')),
        );
        // Trigger a profile refresh
        if (mounted) {
          context.read<AuthBloc>().add(CheckAuthStatus());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          // Mountains background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/image/mountains.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  final user = state.user;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        Center(
                          child: Image.asset(
                            'assets/image/trek_logo.png',
                            height: 64,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 16,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Colors.white,
                                  backgroundImage: (_uploadedImage != null || (user.image != null && user.image!.isNotEmpty))
                                      ? NetworkImage('http://10.0.2.2:3000/uploads/${_uploadedImage ?? user.image}')
                                      : null,
                                  child: (_uploadedImage == null && (user.image == null || user.image!.isEmpty))
                                      ? Icon(Icons.person, size: 44, color: Colors.deepPurple[200])
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FloatingActionButton(
                                heroTag: 'profile_camera',
                                backgroundColor: Colors.white,
                                elevation: 4,
                                mini: true,
                                onPressed: () async {
                                  try {
                                    final prefs = await SharedPreferences.getInstance();
                                    final userId = prefs.getString('user_id') ?? '';
                                    final token = prefs.getString('auth_token') ?? '';
                                    await _pickAndUploadImage(userId, token);
                                  } catch (e) {
                                    print('Error in camera icon tap: ' + e.toString());
                                  }
                                },
                                child: const Icon(Icons.camera_alt, color: Colors.deepPurple, size: 22),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Glassmorphism info card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.72),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: Colors.white70, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 16,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person, color: Colors.deepPurple, size: 26),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            user.fullName.isNotEmpty ? user.fullName : '-',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.email, color: Colors.deepPurple, size: 26),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            user.email,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.phone, color: Colors.deepPurple, size: 26),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            (user.phone != null && user.phone.isNotEmpty) ? user.phone : '-',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.verified_user, color: Colors.deepPurple, size: 26),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            user.role,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    const Divider(height: 32, thickness: 1.2),
                                    Center(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.logout),
                                        label: const Text('Logout'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(180, 48),
                                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.redAccent.withOpacity(0.4),
                                        ),
                                        onPressed: () {
                                          context.read<AuthBloc>().add(LogoutRequested());
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                } else if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text('Not logged in.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 