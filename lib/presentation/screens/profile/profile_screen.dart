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
import '../../widgets/add_trait_dialog.dart';
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
  bool _isAddingTrait = false;

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

  Widget _buildTraitBubbleFromModel(TraitModel trait) {
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
                IconData(int.parse(trait.iconData),
                    fontFamily: 'MaterialIcons'),
                color: Colors.white,
                size: itemHeight * 0.6,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                trait.value,
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

  Widget _buildScrollableChipRow(List<TraitModel> traits) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ...traits.map((trait) => _buildTraitBubbleFromModel(trait)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => _showAddTraitDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAddTraitDialog(BuildContext context) {
    final profileBloc = context.read<ProfileBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AddTraitDialog(
        onTraitAdded: (trait) async {
          setState(() {
            _isAddingTrait = true;
          });

          try {
            profileBloc.add(ProfileTraitAdded(trait));
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${trait.name} trait'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add trait: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          } finally {
            setState(() {
              _isAddingTrait = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildChips(BuildContext context, ProfileState state) {
    if (_showTraits) {
      final user = state.user;
      if (user == null) return const SizedBox.shrink();

      final traitsByCategory = <String, List<TraitModel>>{};
      for (var trait in user.traits) {
        traitsByCategory.putIfAbsent(trait.category, () => []).add(trait);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var category in traitsByCategory.keys) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildScrollableChipRow(traitsByCategory[category]!),
            const SizedBox(height: 8),
          ],
          if (user.traits.isEmpty)
            Center(
              child: TextButton.icon(
                onPressed: () => _showAddTraitDialog(context),
                icon: const Icon(Icons.add, color: Colors.amber),
                label: const Text(
                  'Add your first trait',
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ),
        ],
      );
    } else if (_showNetwork) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScrollableChipRow([
            TraitModel(
              id: '1',
              name: 'Mentors',
              iconData: '0xe559',
              value: 'Mentors',
              category: 'network',
              displayOrder: 0,
            ),
            TraitModel(
              id: '2',
              name: 'Peers',
              iconData: '0xe7ef',
              value: 'Peers',
              category: 'network',
              displayOrder: 1,
            ),
          ]),
        ],
      );
    } else {
      return Text(
        state.user?.username ?? '',
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
        if (state.isLoading && !_isAddingTrait) {
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

        return Stack(
          children: [
            CustomScrollView(
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
                      _buildChips(context, state),
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
            ),
            if (_isAddingTrait)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
