import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/rating_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/post_card.dart';
import '../../widgets/sliding_panel.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/circular_action_button.dart';
import '../../widgets/filtering/menu/filter_menu.dart';
import '../../widgets/filtering/services/filter_service.dart';
import '../../widgets/filtering/models/filter_type.dart';
import '../../widgets/post_creation/in_feed_post_creation.dart';
import '../profile/profile_screen.dart';
import 'feed_bloc/feed_bloc.dart';
import 'feed_bloc/feed_event.dart';
import 'feed_bloc/feed_state.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(
        postRepository: getIt<PostRepository>(),
        authRepository: getIt<AuthRepository>(),
        userRepository: getIt<UserRepository>(),
        filterService: getIt<FilterService>(),
        ratingService: getIt<RatingService>(),
      )..add(const FeedStarted()),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  bool _isProfileOpen = false;
  bool _isCreatingPost = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<InFeedPostCreationState> _postCreationKey =
      GlobalKey<InFeedPostCreationState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent) {
      context.read<FeedBloc>().add(const FeedRefreshed());
    } else if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      context.read<FeedBloc>().add(const FeedLoadMore());
    }
  }

  void _toggleProfile() {
    setState(() {
      _isProfileOpen = !_isProfileOpen;
    });
  }

  void _toggleCreatePost() {
    setState(() {
      _isCreatingPost = !_isCreatingPost;
    });
  }

  void _handlePostCreationComplete(bool success) {
    setState(() {
      _isCreatingPost = false;
    });
    if (success) {
      context.read<FeedBloc>().add(const FeedRefreshed());
    }
  }

  Future<void> _handleActionButton() async {
    if (_isCreatingPost) {
      final state = _postCreationKey.currentState;
      if (state != null) {
        await state.save();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not save post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      _toggleCreatePost();
    }
  }

  void _applyFilter(FilterType filterType) {
    context.read<FeedBloc>().add(FeedFilterChanged(filterType));
  }

  void _handleSearch(String query) {
    context.read<FeedBloc>().add(FeedSearchChanged(query));
  }

  List<Rect> _getExcludedAreas(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return [
      Rect.fromLTWH(
        0, 
        size.height - bottomPadding - 88,
        size.width,
        88 + bottomPadding,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedGradientBackground(
            child: Column(
              children: [
                Container(
                  height: 64 + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: FilterMenu(
                      onGroupFilter: () {
                        _applyFilter(FilterType.group);
                      },
                      onPairFilter: () {
                        _applyFilter(FilterType.pair);
                      },
                      onSelfFilter: () {
                        _applyFilter(FilterType.self);
                      },
                      onSearch: _handleSearch,
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<FeedBloc, FeedState>(
                    builder: (context, state) {
                      if (state is FeedInitial || state is FeedLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }

                      if (state is FeedFailure) {
                        return ErrorView(
                          message: state.error,
                          onRetry: () {
                            context.read<FeedBloc>().add(const FeedStarted());
                          },
                        );
                      }

                      if (state is FeedSuccess &&
                          state.posts.isEmpty &&
                          !_isCreatingPost) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.post_add,
                                size: 64,
                                color: Colors.white70,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No posts yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to create a post!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              CircularActionButton(
                                icon: Icons.add,
                                onPressed: _toggleCreatePost,
                                isBold: true,
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is FeedSuccess) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                          itemCount: state.posts.length +
                              (_isCreatingPost ? 1 : 0) +
                              (state is FeedLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isCreatingPost && index == 0) {
                              return InFeedPostCreation(
                                key: _postCreationKey,
                                onCancel: _toggleCreatePost,
                                onComplete: _handlePostCreationComplete,
                              );
                            }

                            final postIndex =
                                _isCreatingPost ? index - 1 : index;

                            if (postIndex >= state.posts.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              );
                            }

                            final post = state.posts[postIndex];
                            return PostCard(
                              post: post,
                              currentUserId: state.currentUserId,
                              onLike: () {
                                context
                                    .read<FeedBloc>()
                                    .add(FeedPostLiked(post.id));
                              },
                              onComment: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Comments coming soon!')),
                                );
                              },
                              onShare: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Share feature coming soon!')),
                                );
                              },
                              onRate: (rating) {
                                context
                                    .read<FeedBloc>()
                                    .add(FeedPostRated(post.id, rating));
                              },
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularActionButton(
                    icon: Icons.person,
                    onPressed: _toggleProfile,
                  ),
                  CircularActionButton(
                    icon: _isCreatingPost ? Icons.check : Icons.add,
                    onPressed: () async {
                      await _handleActionButton();
                    },
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          SlidingPanel(
            isOpen: _isProfileOpen,
            onClose: _toggleProfile,
            excludeFromOverlay: _getExcludedAreas(context),
            child: const ProfileScreen(),
          ),
        ],
      ),
    );
  }
}
