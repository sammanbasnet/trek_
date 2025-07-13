import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              final UserEntity user = state.user;
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        child: Text(
                          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Name: ${user.fullName}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Phone: ${user.phone}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Role: ${user.role}', style: const TextStyle(fontSize: 18)),
                    const Spacer(),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(150, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                    ),
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
    );
  }
} 