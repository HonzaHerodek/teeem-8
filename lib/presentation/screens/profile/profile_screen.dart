import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/rating_service.dart';
import '../../../data/models/targeting_model.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/post_card.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/rating_stars.dart';
import 'profile_bloc/profile_bloc.dart';
import 'profile_bloc/profile_event.dart';
import 'profile_bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: getIt<UserRepository>(),
        postRepository: getIt<PostRepository>(),
        ratingService: getIt<RatingService>(),
      )..add(const ProfileStarted()),
      child: const Scaffold(
        body: SafeArea(
          child: ProfileView(),
        ),
      ),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _interestsController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _languagesController = TextEditingController();
  final _skillsController = TextEditingController();
  final _industriesController = TextEditingController();
  String? _selectedExperienceLevel;
  bool _showRatingStats = false;

  @override
  void dispose() {
    _interestsController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _languagesController.dispose();
    _skillsController.dispose();
    _industriesController.dispose();
    super.dispose();
  }

  void _initializeControllers(TargetingCriteria? targeting) {
    if (!mounted) return;
    setState(() {
      _interestsController.text = targeting?.interests?.join(', ') ?? '';
      _minAgeController.text = targeting?.minAge?.toString() ?? '';
      _maxAgeController.text = targeting?.maxAge?.toString() ?? '';
      _languagesController.text = targeting?.languages?.join(', ') ?? '';
      _skillsController.text = targeting?.skills?.join(', ') ?? '';
      _industriesController.text = targeting?.industries?.join(', ') ?? '';
      _selectedExperienceLevel = targeting?.experienceLevel;
    });
  }

  List<String>? _parseCommaSeparatedList(String value) {
    if (value.isEmpty) return null;
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _saveTargeting(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final targeting = TargetingCriteria(
        interests: _parseCommaSeparatedList(_interestsController.text),
        minAge: int.tryParse(_minAgeController.text),
        maxAge: int.tryParse(_maxAgeController.text),
        languages: _parseCommaSeparatedList(_languagesController.text),
        skills: _parseCommaSeparatedList(_skillsController.text),
        industries: _parseCommaSeparatedList(_industriesController.text),
        experienceLevel: _selectedExperienceLevel,
      );

      context.read<ProfileBloc>().add(ProfileTargetingUpdated(targeting));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content preferences updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isInitial) {
          return const LoadingIndicator();
        }

        if (state.user == null) {
          return ErrorView(
            message: state.error ?? 'Failed to load profile',
            onRetry: () {
              context.read<ProfileBloc>().add(const ProfileStarted());
            },
          );
        }

        final user = state.user!;

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(const ProfileRefreshed());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        if (state.ratingStats != null) ...[
                          RatingStars(
                            rating: state.ratingStats!.averageRating,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${state.ratingStats!.averageRating.toStringAsFixed(1)} (${state.ratingStats!.totalRatings} ${state.ratingStats!.totalRatings == 1 ? 'rating' : 'ratings'})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                        ],
                        UserAvatar(
                          imageUrl: user.profileImage,
                          name: user.username,
                          size: 100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.username,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (user.hasBio) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              user.bio!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (state.ratingStats != null && _showRatingStats) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: RatingStatsDisplay(
                              averageRating: state.ratingStats!.averageRating,
                              totalRatings: state.ratingStats!.totalRatings,
                              distribution:
                                  state.ratingStats!.ratingDistribution,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(context, 'Posts',
                                  state.userPosts.length.toString()),
                              _buildStatColumn(context, 'Followers',
                                  user.followersCount.toString()),
                              _buildStatColumn(context, 'Following',
                                  user.followingCount.toString()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        ExpansionTile(
                          title: const Text('Content Preferences'),
                          subtitle: const Text('Customize your feed'),
                          onExpansionChanged: (expanded) {
                            if (expanded) {
                              _initializeControllers(user.targetingCriteria);
                            }
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _interestsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Interests',
                                        hintText:
                                            'e.g., coding, design, marketing',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _minAgeController,
                                            decoration: const InputDecoration(
                                              labelText: 'Min Age',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                final age = int.tryParse(value);
                                                if (age == null || age < 0) {
                                                  return 'Invalid age';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _maxAgeController,
                                            decoration: const InputDecoration(
                                              labelText: 'Max Age',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                final age = int.tryParse(value);
                                                if (age == null || age < 0) {
                                                  return 'Invalid age';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: _selectedExperienceLevel,
                                      decoration: const InputDecoration(
                                        labelText: 'Experience Level',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: null, child: Text('Any')),
                                        DropdownMenuItem(
                                            value: 'beginner',
                                            child: Text('Beginner')),
                                        DropdownMenuItem(
                                            value: 'intermediate',
                                            child: Text('Intermediate')),
                                        DropdownMenuItem(
                                            value: 'advanced',
                                            child: Text('Advanced')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedExperienceLevel = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _languagesController,
                                      decoration: const InputDecoration(
                                        labelText: 'Languages',
                                        hintText:
                                            'e.g., English, Spanish, French',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _skillsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Skills',
                                        hintText:
                                            'e.g., Flutter, React, Python',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _industriesController,
                                      decoration: const InputDecoration(
                                        labelText: 'Industries',
                                        hintText:
                                            'e.g., Technology, Healthcare, Finance',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () => _saveTargeting(context),
                                      child: const Text('Save Preferences'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                  if (state.userPosts.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('No posts yet'),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(8.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = state.userPosts[index];
                            return PostCard(
                              post: post,
                              currentUserId: user.id,
                              onLike: () {
                                // TODO: Implement like functionality
                              },
                              onComment: () {
                                // TODO: Implement comment functionality
                              },
                              onShare: () {
                                // TODO: Implement share functionality
                              },
                              onRate: (rating) {
                                context.read<ProfileBloc>().add(
                                      ProfileRatingReceived(rating, user.id),
                                    );
                              },
                            );
                          },
                          childCount: state.userPosts.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (state.isLoading)
              const LoadingOverlay(
                isLoading: true,
                child: SizedBox.shrink(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class RatingStatsDisplay extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> distribution;

  const RatingStatsDisplay({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Rating Distribution',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (var i = 5; i >= 1; i--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text('$i star'),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: totalRatings > 0
                        ? (distribution[i] ?? 0) / totalRatings
                        : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${distribution[i] ?? 0}'),
              ],
            ),
          ),
      ],
    );
  }
}
