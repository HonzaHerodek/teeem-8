import '../../../../data/models/targeting_model.dart';
import '../../../widgets/filtering/models/filter_type.dart';

abstract class FeedEvent {
  const FeedEvent();

  List<Object?> get props => [];
}

class FeedStarted extends FeedEvent {
  const FeedStarted();
}

class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}

class FeedLoadMore extends FeedEvent {
  const FeedLoadMore();
}

class FeedPostLiked extends FeedEvent {
  final String postId;

  const FeedPostLiked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class FeedPostUnliked extends FeedEvent {
  final String postId;

  const FeedPostUnliked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class FeedPostDeleted extends FeedEvent {
  final String postId;

  const FeedPostDeleted(this.postId);

  @override
  List<Object?> get props => [postId];
}

class FeedPostHidden extends FeedEvent {
  final String postId;

  const FeedPostHidden(this.postId);

  @override
  List<Object?> get props => [postId];
}

class FeedPostSaved extends FeedEvent {
  final String postId;

  const FeedPostSaved(this.postId);

  @override
  List<Object?> get props => [postId];
}

class FeedPostUnsaved extends FeedEvent {
  final String postId;

  const FeedPostUnsaved(this.postId);

  @override
  List<Object?> get props => [postId];
}

class FeedPostReported extends FeedEvent {
  final String postId;
  final String reason;

  const FeedPostReported(this.postId, this.reason);

  @override
  List<Object?> get props => [postId, reason];
}

class FeedPostRated extends FeedEvent {
  final String postId;
  final double rating;

  const FeedPostRated(this.postId, this.rating);

  @override
  List<Object?> get props => [postId, rating];
}

class FeedFilterChanged extends FeedEvent {
  final FilterType filterType;

  const FeedFilterChanged(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class FeedTargetingFilterChanged extends FeedEvent {
  final TargetingCriteria? targetingCriteria;

  const FeedTargetingFilterChanged(this.targetingCriteria);

  @override
  List<Object?> get props => [targetingCriteria];
}

class FeedSearchChanged extends FeedEvent {
  final String query;

  const FeedSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
