import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/rating_service.dart';
import '../../../data/models/targeting_model.dart';
import '../../../data/models/trait_model.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/post_card.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/circular_action_button.dart';
import 'profile_bloc/profile_bloc.dart';
import 'profile_bloc/profile_event.dart';
import 'profile_bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: getIt<UserRepository>(),
        postRepository: getIt<PostRepository>(),
        ratingService: getIt<RatingService>(),
      )..add(const ProfileStarted()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.51),
              Colors.black.withOpacity(0.45),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: const SafeArea(
              child: ProfileView(),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _industriesController = TextEditingController();
  String? _selectedExperienceLevel;
  bool _showTraits = false;
  bool _showNetwork = false;

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

  Widget _buildTraitBubble(String text, IconData icon) {
    const double itemHeight = 40;
    const double itemWidth = 120;

    return Container(
      width: itemWidth,
      height: itemHeight,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(itemHeight / 2),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: itemHeight,
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(itemHeight / 2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: itemHeight * 0.6,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableChipRow(List<MapEntry<String, IconData>> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items
            .map((item) => _buildTraitBubble(item.key, item.value))
            .toList(),
      ),
    );
  }

  Widget _buildChips(String username) {
    if (_showTraits) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScrollableChipRow([
            const MapEntry('Creative', Icons.palette),
            const MapEntry('Strategic', Icons.psychology),
            const MapEntry('Analytical', Icons.analytics),
            const MapEntry('Innovative', Icons.lightbulb),
          ]),
          const SizedBox(height: 8),
          _buildScrollableChipRow([
            const MapEntry('Leadership', Icons.group),
            const MapEntry('Communication', Icons.chat),
            const MapEntry('Problem Solving', Icons.build),
            const MapEntry('Decision Making', Icons.fact_check),
          ]),
          const SizedBox(height: 8),
          _buildScrollableChipRow([
            const MapEntry('Innovation', Icons.rocket_launch),
            const MapEntry('Teamwork', Icons.people),
            const MapEntry('Adaptability', Icons.sync),
            const MapEntry('Critical Thinking', Icons.psychology_alt),
          ]),
        ],
      );
    } else if (_showNetwork) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScrollableChipRow([
            const MapEntry('Mentors', Icons.school),
            const MapEntry('Peers', Icons.group),
            const MapEntry('Alumni', Icons.workspace_premium),
            const MapEntry('Partners', Icons.handshake),
          ]),
          const SizedBox(height: 8),
          _buildScrollableChipRow([
            const MapEntry('Industry', Icons.business),
            const MapEntry('Academic', Icons.menu_book),
            const MapEntry('Research', Icons.science),
            const MapEntry('Professional', Icons.work),
          ]),
          const SizedBox(height: 8),
          _buildScrollableChipRow([
            const MapEntry('Startups', Icons.rocket),
            const MapEntry('Corporate', Icons.corporate_fare),
            const MapEntry('Nonprofit', Icons.volunteer_activism),
            const MapEntry('Government', Icons.account_balance),
          ]),
        ],
      );
    } else {
      return Text(
        username,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          );
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

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (state.ratingStats != null) ...[
                    RatingStars(
                      rating: state.ratingStats!.averageRating,
                      size: 36,
                      color: Colors.amber,
                      distribution: state.ratingStats!.ratingDistribution,
                      totalRatings: state.ratingStats!.totalRatings,
                      showRatingText: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularActionButton(
                        icon: Icons.psychology,
                        onPressed: () {
                          setState(() {
                            _showTraits = !_showTraits;
                            _showNetwork = false;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      UserAvatar(
                        imageUrl: user.profileImage,
                        name: user.username,
                        size: 100,
                      ),
                      const SizedBox(width: 16),
                      CircularActionButton(
                        icon: Icons.people,
                        onPressed: () {
                          setState(() {
                            _showNetwork = !_showNetwork;
                            _showTraits = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildChips(user.username),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                ],
              ),
            ),
            if (state.userPosts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No posts yet',
                    style: TextStyle(color: Colors.white70),
                  ),
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
        );
      },
    );
  }
}
