import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/errors/app_exception.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const AuthState.initial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Check initial auth state
    add(const AuthStarted());
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userId: currentUser.id,
          username: currentUser.username,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e is AppException ? e : AppException(e.toString()),
      ));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.id,
          username: user.username,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          error: AppException('Failed to sign in'),
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e is AppException ? e : AppException(e.toString()),
      ));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signUpWithEmailAndPassword(
        event.email,
        event.password,
        event.username,
      );
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.id,
          username: user.username,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          error: AppException('Failed to sign up'),
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e is AppException ? e : AppException(e.toString()),
      ));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      await _authRepository.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        userId: null,
        username: null,
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e is AppException ? e : AppException(e.toString()),
      ));
    }
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userId: currentUser.id,
        username: currentUser.username,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        userId: null,
        username: null,
      ));
    }
  }
}
