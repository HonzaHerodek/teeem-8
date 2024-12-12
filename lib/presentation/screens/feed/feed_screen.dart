import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/step_type_repository.dart';
import '../../../core/services/rating_service.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../widgets/error_view.dart';
import '../../widgets/post_card.dart';
import '../../widgets/sliding_panel.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/circular_action_button.dart';
import '../../widgets/filtering/menu/filter_menu.dart';
import '../../widgets/filtering/services/filter_service.dart';
import '../../widgets/filtering/models/filter_type.dart';
import '../../widgets/post_creation/in_feed_post_creation.dart';
import '../../widgets/post_creation/post_step_widget.dart';
import '../../bloc/auth/auth_bloc.dart';
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
  bool _isLoading = false;

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
      print('Attempting to save post...'); // Debug print
      final controller = InFeedPostCreation.of(context);
      if (controller != null) {
        print('Found controller, saving...'); // Debug print
        await controller.save();
      } else {
        print('Controller not found'); // Debug print
      }
    } else {
      _toggleCreatePost();
    }
  }

  void _applyFilter(FilterType filterType) {
    print('_applyFilter called with type: ${filterType.displayName}');
    context.read<FeedBloc>().add(FeedFilterChanged(filterType));
  }

  void _handleSearch(String query) {
    print('_handleSearch called with query: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedGradientBackground(
            child: Column(
              children: [
                // Top Bar with Filter
                Container(
                  height: 64 + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    right: 16,
                  ),
                  alignment: Alignment.topRight,
                  child: FilterMenu(
                    onGroupFilter: () {
                      print('Group filter callback');
                      _applyFilter(FilterType.group);
                    },
                    onPairFilter: () {
                      print('Pair filter callback');
                      _applyFilter(FilterType.pair);
                    },
                    onSelfFilter: () {
                      print('Self filter callback');
                      _applyFilter(FilterType.self);
                    },
                    onSearch: _handleSearch,
                  ),
                ),
                // Content
                Expanded(
                  child: BlocBuilder<FeedBloc, FeedState>(
                    builder: (context, state) {
                      if (state.isInitial || state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }

                      if (state.isFailure) {
                        return ErrorView(
                          message:
                              state.error?.message ?? 'Something went wrong',
                          onRetry: () {
                            context.read<FeedBloc>().add(const FeedStarted());
                          },
                        );
                      }

                      if (state.posts.isEmpty && !_isCreatingPost) {
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

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                        itemCount: state.posts.length +
                            (_isCreatingPost ? 1 : 0) +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isCreatingPost && index == 0) {
                            return Form(
                              key: _formKey,
                              child: InFeedPostCreation(
                                onCancel: _toggleCreatePost,
                                onComplete: _handlePostCreationComplete,
                              ),
                            );
                          }

                          final postIndex = _isCreatingPost ? index - 1 : index;

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
                                  content: Text('Comments coming soon!'),
                                ),
                              );
                            },
                            onShare: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Share feature coming soon!'),
                                ),
                              );
                            },
                            onRate: (rating) {
                              context.read<FeedBloc>().add(
                                    FeedPostRated(post.id, rating),
                                  );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bottom Buttons
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
                    onPressed: _isLoading ? null : () => _handleActionButton(),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          // Profile Panel
          SlidingPanel(
            isOpen: _isProfileOpen,
            onClose: _toggleProfile,
            child: const ProfileScreen(),
          ),
        ],
      ),
    );
  }
}
