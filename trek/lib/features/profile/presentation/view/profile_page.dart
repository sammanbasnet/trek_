import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'dart:ui';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        child: Stack(
          children: [
            // Background mountain image with opacity
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  final UserEntity user = state.user;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Trekking themed header
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 180,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFff5858), Color(0xFFf857a6)],
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                ),
                              ),
                              // No sign or icon, just the gradient
                            ),
                            // Avatar
                            Positioned(
                              bottom: -48, // slightly less overlap
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.lightBlue[100],
                                    child: Icon(Icons.hiking, size: 48, color: Colors.deepPurple),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 72), // more space below avatar
                        // Glassmorphism card for user info
                        Center(
                          child: Container(
                            width: screenWidth > 400 ? 370 : screenWidth * 0.92,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
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
                                              user.phone.isNotEmpty ? user.phone : '-',
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
          ],
        ),
      ),
    );
  }
} 