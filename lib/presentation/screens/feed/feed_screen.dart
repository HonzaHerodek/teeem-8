import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/feed_filter_service.dart';
import '../../../core/services/menu_configuration_service.dart';
import '../../../core/services/rating_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/post_card.dart';
import '../../widgets/sliding_panel.dart';
import '../../widgets/radial_menu.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/circular_action_button.dart';
import '../profile/profile_screen.dart';
import '../create_post/create_post_screen.dart';
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
        feedFilterService: getIt<FeedFilterService>(),
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
  final ScrollController _scrollController = ScrollController();
  final _menuConfigurationService = getIt<MenuConfigurationService>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  Future<void> _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );

    if (result == true && mounted) {
      context.read<FeedBloc>().add(const FeedRefreshed());
    }
  }

  void _applyFilter(FilterType filterType) {
    context.read<FeedBloc>().add(FeedFilterChanged(filterType));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedGradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                if (state.isInitial || state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (state.isFailure) {
                  return ErrorView(
                    message: state.error?.message ?? 'Something went wrong',
                    onRetry: () {
                      context.read<FeedBloc>().add(const FeedStarted());
                    },
                  );
                }

                if (state.posts.isEmpty) {
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
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to create a post!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        CircularActionButton(
                          icon: Icons.add,
                          onPressed: _navigateToCreatePost,
                          isBold: true,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.posts.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    }

                    final post = state.posts[index];
                    return PostCard(
                      post: post,
                      currentUserId: state.currentUserId,
                      onLike: () {
                        context.read<FeedBloc>().add(FeedPostLiked(post.id));
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
            floatingActionButton: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                      ),
                      child: RadialMenu(
                        items: _menuConfigurationService
                            .getFeedTopRightMenu(
                              onFilterSelected: _applyFilter,
                            )
                            .items,
                        mainIcon: Icons.filter_list,
                        alignment: RadialMenuAlignment.topRight,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: CircularActionButton(
                            icon: Icons.person,
                            onPressed: _toggleProfile,
                          ),
                        ),
                        CircularActionButton(
                          icon: Icons.add,
                          onPressed: _navigateToCreatePost,
                          isBold: true,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SlidingPanel(
          isOpen: _isProfileOpen,
          onClose: _toggleProfile,
          child: const ProfileScreen(),
        ),
      ],
    );
  }
}
