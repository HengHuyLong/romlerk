import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/mock_user_repo.dart';

// Provider for the current user
final userProvider = Provider<User>((ref) {
  return MockUserRepo.getUser();
});
