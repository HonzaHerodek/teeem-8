import '../../../../data/models/post_model.dart';
import '../../../../data/models/user_model.dart';
import '../models/filter_type.dart';

class FilterService {
  FilterType _currentFilter = FilterType.none;

  FilterType get currentFilter => _currentFilter;

  void setFilter(FilterType filter) {
    _currentFilter = filter;
  }

  List<PostModel> filterPosts(List<PostModel> posts, UserModel currentUser) {
    // First apply targeting criteria filter
    var filteredPosts = posts.where((post) => _shouldShowPost(post, currentUser)).toList();

    // Then apply the selected filter type
    switch (_currentFilter) {
      case FilterType.group:
        return filteredPosts.where((post) {
          final interests = post.targetingCriteria?.interests?.length ?? 0;
          final skills = post.targetingCriteria?.skills?.length ?? 0;
          return interests > 2 || skills > 2;
        }).toList();
      
      case FilterType.pair:
        return filteredPosts.where((post) {
          final interests = post.targetingCriteria?.interests?.length ?? 0;
          final skills = post.targetingCriteria?.skills?.length ?? 0;
          return interests == 2 || skills == 2;
        }).toList();
      
      case FilterType.self:
        return filteredPosts.where((post) {
          if (post.userId == currentUser.id) return true;
          final interests = post.targetingCriteria?.interests?.length ?? 0;
          final skills = post.targetingCriteria?.skills?.length ?? 0;
          return interests <= 1 && skills <= 1;
        }).toList();
      
      case FilterType.none:
      default:
        return filteredPosts;
    }
  }

  bool _shouldShowPost(PostModel post, UserModel currentUser) {
    // Check if post is active
    if (post.status != PostStatus.active) {
      return false;
    }

    // Check targeting criteria
    if (post.targetingCriteria != null &&
        currentUser.targetingCriteria != null) {
      if (!post.isTargetedTo(currentUser.targetingCriteria!)) {
        return false;
      }
    }

    return true;
  }
}
