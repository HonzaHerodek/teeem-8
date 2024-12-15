import 'package:equatable/equatable.dart';
import 'package:myapp/data/models/post_model.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoadingMore extends FeedState {
  final List<PostModel> posts;

  const FeedLoadingMore({required this.posts});

  @override
  List<Object> get props => [posts];
}

class FeedSuccess extends FeedState {
  final List<PostModel> posts;
  final String currentUserId;

  const FeedSuccess({required this.posts, required this.currentUserId});

  @override
  List<Object> get props => [posts, currentUserId];
}

class FeedFailure extends FeedState {
  final String error;

  const FeedFailure({String? error}) : error = error ?? 'An error occurred';

  @override
  List<Object> get props => [error];
}
