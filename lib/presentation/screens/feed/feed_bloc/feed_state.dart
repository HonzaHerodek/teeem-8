import '../../../../core/errors/app_exception.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/targeting_model.dart';
import '../../../widgets/filtering/models/filter_type.dart';

enum FeedStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore,
}

class FeedState {
  final FeedStatus status;
  final List<PostModel> posts;
  final bool hasReachedMax;
  final String? currentUserId;
  final String? lastPostId;
  final AppException? error;
  final bool isRefreshing;
  final TargetingCriteria? targetingFilter;
  final FilterType currentFilter;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.hasReachedMax = false,
    this.currentUserId,
    this.lastPostId,
    this.error,
    this.isRefreshing = false,
    this.targetingFilter,
    this.currentFilter = FilterType.none,
  });

  bool get isInitial => status == FeedStatus.initial;
  bool get isLoading => status == FeedStatus.loading;
  bool get isSuccess => status == FeedStatus.success;
  bool get isFailure => status == FeedStatus.failure;
  bool get isLoadingMore => status == FeedStatus.loadingMore;

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel>? posts,
    bool? hasReachedMax,
    String? currentUserId,
    String? lastPostId,
    AppException? error,
    bool? isRefreshing,
    TargetingCriteria? targetingFilter,
    FilterType? currentFilter,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentUserId: currentUserId ?? this.currentUserId,
      lastPostId: lastPostId ?? this.lastPostId,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      targetingFilter: targetingFilter ?? this.targetingFilter,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  List<Object?> get props => [
        status,
        posts,
        hasReachedMax,
        currentUserId,
        lastPostId,
        error,
        isRefreshing,
        targetingFilter,
        currentFilter,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedState &&
        other.status == status &&
        other.posts == posts &&
        other.hasReachedMax == hasReachedMax &&
        other.currentUserId == currentUserId &&
        other.lastPostId == lastPostId &&
        other.error == error &&
        other.isRefreshing == isRefreshing &&
        other.targetingFilter == targetingFilter &&
        other.currentFilter == currentFilter;
  }

  @override
  int get hashCode =>
      status.hashCode ^
      posts.hashCode ^
      hasReachedMax.hashCode ^
      currentUserId.hashCode ^
      lastPostId.hashCode ^
      error.hashCode ^
      isRefreshing.hashCode ^
      targetingFilter.hashCode ^
      currentFilter.hashCode;
}
