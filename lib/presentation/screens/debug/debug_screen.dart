import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/post_card.dart';
import '../feed/feed_bloc/feed_bloc.dart';
import '../feed/feed_bloc/feed_event.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh the feed
              context.read<FeedBloc>().add(const FeedStarted());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAuthSection(),
            const Divider(height: 32),
            _buildPostSection(),
            const Divider(height: 32),
            _buildUserSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Authentication',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Status: ${state.status}'),
                Text('User ID: ${state.userId ?? 'None'}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthSignInRequested(
                                email: 'test@example.com',
                                password: 'password123',
                              ),
                            );
                      },
                      child: const Text('Test Sign In'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthSignOutRequested());
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return FutureBuilder(
          future: getIt<PostRepository>().getPosts(limit: 1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No posts available'),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Sample Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PostCard(
                  post: posts.first,
                  currentUserId: authState.userId,
                  onLike: () {},
                  onComment: () {},
                  onShare: () {},
                  onRate: (rating) {
                    // Handle rating in debug mode
                    debugPrint('Debug: Rating changed to $rating');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserSection() {
    return FutureBuilder(
      future: getIt<UserRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  Text('Error: ${snapshot.error}')
                else if (snapshot.data == null)
                  const Text('No user logged in')
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${snapshot.data!.id}'),
                      Text('Username: ${snapshot.data!.username}'),
                      Text('Email: ${snapshot.data!.email}'),
                      Text('Followers: ${snapshot.data!.followers.length}'),
                      Text('Following: ${snapshot.data!.following.length}'),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
