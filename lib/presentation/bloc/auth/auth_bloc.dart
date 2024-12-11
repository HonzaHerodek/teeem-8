import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/errors/app_exception.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  StreamSubscription<bool>? _authStateSubscription;

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

    // Start listening to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (isAuthenticated) {
        add(AuthStateChanged(isAuthenticated: isAuthenticated));
      },
    );

    // Check initial auth state
    add(const AuthStarted());
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final isSignedIn = await _authRepository.isSignedIn();
      if (isSignedIn) {
        final userId = await _authRepository.getCurrentUserId();
        final user = await _userRepository.getUserById(userId!);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userId: userId,
          username: user?.username,
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
      await _authRepository.signIn(event.email, event.password);
      final userId = await _authRepository.getCurrentUserId();
      final user = await _userRepository.getUserById(userId!);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        username: user?.username,
      ));
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
      await _authRepository.signUp(
        event.email,
        event.password,
        event.username,
      );
      final userId = await _authRepository.getCurrentUserId();
      final user = await _userRepository.getUserById(userId!);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        username: user?.username,
      ));
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
    if (event.isAuthenticated) {
      final userId = await _authRepository.getCurrentUserId();
      final user = await _userRepository.getUserById(userId!);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        username: user?.username,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        userId: null,
        username: null,
      ));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
