import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import 'profile_state.dart';

/// Loads and exposes user profile data from local preferences.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UserPrefsRepository repository})
    : _repository = repository,
      super(const ProfileState.initial());

  final UserPrefsRepository _repository;

  /// Reads persisted profile data and emits a new state.
  void loadProfile() {
    emit(
      ProfileState(
        userName: _repository.getUserName(),
        cookedCount: _repository.getCookedCount(),
        savedCount: _repository.getSavedCount(),
      ),
    );
  }
}
