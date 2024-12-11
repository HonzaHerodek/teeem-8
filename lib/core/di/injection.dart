import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../services/connectivity_service.dart';
import '../services/feed_filter_service.dart';
import '../services/logger_service.dart';
import '../services/menu_configuration_service.dart';
import '../services/rating_service.dart';
import '../services/test_data_service.dart';
import '../services/trait_service.dart';
import '../navigation/navigation_service.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firebase_post_repository.dart';
import '../../data/repositories/firebase_rating_service.dart';
import '../../data/repositories/firebase_step_type_repository.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/mock_post_repository.dart';
import '../../data/repositories/mock_rating_service.dart';
import '../../data/repositories/mock_step_type_repository.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/step_type_repository.dart';
import '../../domain/repositories/user_repository.dart';

final getIt = GetIt.instance;

const bool kIsDebug = bool.fromEnvironment('dart.vm.product') == false;

void setupDependencies() {
  // Core Services
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<FeedFilterService>(() => FeedFilterService());
  getIt.registerLazySingleton<TestDataService>(() => TestDataService());
  getIt.registerLazySingleton<TraitService>(() => TraitService());
  getIt.registerLazySingleton<MenuConfigurationService>(() => MenuConfigurationService());

  if (kIsDebug) {
    // Debug implementations
    getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
    getIt.registerLazySingleton<PostRepository>(() => MockPostRepository());
    getIt.registerLazySingleton<StepTypeRepository>(() => MockStepTypeRepository());
    getIt.registerLazySingleton<UserRepository>(() => MockUserRepository());
    getIt.registerLazySingleton<RatingService>(() => MockRatingService());
  } else {
    // Firebase instance
    getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

    // Production implementations
    getIt.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository());
    getIt.registerLazySingleton<PostRepository>(() => FirebasePostRepository());
    getIt.registerLazySingleton<StepTypeRepository>(() => FirebaseStepTypeRepository());
    getIt.registerLazySingleton<UserRepository>(() => FirebaseUserRepository());
    getIt.registerLazySingleton<RatingService>(
      () => FirebaseRatingService(
        firestore: getIt<FirebaseFirestore>(),
        logger: getIt<LoggerService>(),
      ),
    );
  }
}
