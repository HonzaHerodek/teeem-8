abstract class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Stream<bool> get authStateChanges;
  Future<String?> getCurrentUserId();
}
