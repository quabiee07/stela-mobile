import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/profile/data/services/profile_firebase_service.dart';

class EditProfileState extends Equatable {
  const EditProfileState({
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.password = '',
    this.email = '',
    this.phoneNumber = '',
    this.avatarUrl = femaleAvatar,
    this.localImagePath,
    this.isSaving = false,
    this.isPickingImage = false,
    this.isDirty = false,
    this.isHydrated = false,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String email;
  final String phoneNumber;

  /// Saved avatar value: asset path or remote download URL.
  final String avatarUrl;

  /// Pending local file from gallery/camera (uploaded on save).
  final String? localImagePath;

  final bool isSaving;
  final bool isPickingImage;
  final bool isDirty;
  final bool isHydrated;

  String get fullName {
    final parts = [firstName.trim(), lastName.trim()]
        .where((part) => part.isNotEmpty);
    return parts.join(' ');
  }

  bool get canSave =>
      isDirty &&
      !isSaving &&
      !isPickingImage &&
      firstName.trim().isNotEmpty &&
      email.trim().isNotEmpty;

  EditProfileState copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? localImagePath,
    bool clearLocalImage = false,
    bool? isSaving,
    bool? isPickingImage,
    bool? isDirty,
    bool? isHydrated,
  }) {
    return EditProfileState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localImagePath:
          clearLocalImage ? null : (localImagePath ?? this.localImagePath),
      isSaving: isSaving ?? this.isSaving,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      isDirty: isDirty ?? this.isDirty,
      isHydrated: isHydrated ?? this.isHydrated,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        username,
        password,
        email,
        phoneNumber,
        avatarUrl,
        localImagePath,
        isSaving,
        isPickingImage,
        isDirty,
        isHydrated,
      ];
}

sealed class EditProfileEffect {
  const EditProfileEffect();
}

final class EditProfileSavedEffect extends EditProfileEffect {
  const EditProfileSavedEffect();
}

final class EditProfileErrorEffect extends EditProfileEffect {
  const EditProfileErrorEffect(this.message);
  final String message;
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._firebase) : super(const EditProfileState()) {
    unawaited(_hydrate());
  }

  final ProfileFirebaseService _firebase;
  final _picker = ImagePicker();
  final _effects = StreamController<EditProfileEffect>.broadcast();

  Stream<EditProfileEffect> get effects => _effects.stream;

  static const avatarChoices = [
    femaleAvatar,
    avatar1,
    avatar2,
    avatar3,
    avatar4,
    avatar5,
  ];

  Future<void> _hydrate() async {
    final user = cachedUser ?? await getCachedUser();
    if (user == null) {
      emit(state.copyWith(isHydrated: true));
      return;
    }

    final nameParts = user.name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    var username = '';
    var phoneNumber = '';
    var avatarUrl = _resolveAvatar(user.avatarUrl);

    try {
      final remote = await _firebase.getProfile(user.id);
      username = (remote['username'] as String?)?.trim() ?? '';
      phoneNumber = (remote['phoneNumber'] as String?)?.trim() ?? '';
      final remoteAvatar = remote['avatarUrl'] as String?;
      if (remoteAvatar != null && remoteAvatar.isNotEmpty) {
        avatarUrl = _resolveAvatar(remoteAvatar);
      }
    } catch (_) {
      // Offline / missing doc — fall back to cached user only.
    }

    if (isClosed) return;
    emit(
      EditProfileState(
        firstName: firstName,
        lastName: lastName,
        username: username.isNotEmpty
            ? username
            : _defaultUsername(firstName, user.email),
        email: user.email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        isHydrated: true,
      ),
    );
  }

  String _defaultUsername(String firstName, String email) {
    if (firstName.isNotEmpty) return firstName.toLowerCase();
    final local = email.split('@').first;
    return local.isNotEmpty ? local : '';
  }

  String _resolveAvatar(String avatarUrl) {
    if (avatarUrl.isEmpty) return femaleAvatar;
    if (avatarChoices.contains(avatarUrl)) return avatarUrl;
    if (avatarUrl.startsWith('http://') ||
        avatarUrl.startsWith('https://') ||
        avatarUrl.startsWith('assets/') ||
        avatarUrl.startsWith('/')) {
      return avatarUrl;
    }
    return femaleAvatar;
  }

  void setFirstName(String value) {
    if (value == state.firstName) return;
    emit(state.copyWith(firstName: value, isDirty: true));
  }

  void setLastName(String value) {
    if (value == state.lastName) return;
    emit(state.copyWith(lastName: value, isDirty: true));
  }

  void setUsername(String value) {
    if (value == state.username) return;
    emit(state.copyWith(username: value, isDirty: true));
  }

  void setPassword(String value) {
    if (value == state.password) return;
    emit(state.copyWith(password: value, isDirty: true));
  }

  void setEmail(String value) {
    if (value == state.email) return;
    emit(state.copyWith(email: value, isDirty: true));
  }

  void setPhoneNumber(String value) {
    if (value == state.phoneNumber) return;
    emit(state.copyWith(phoneNumber: value, isDirty: true));
  }

  void setAvatarAsset(String asset) {
    if (asset == state.avatarUrl && state.localImagePath == null) return;
    emit(
      state.copyWith(
        avatarUrl: asset,
        clearLocalImage: true,
        isDirty: true,
      ),
    );
  }

  Future<void> pickFromGallery() => _pickImage(ImageSource.gallery);

  Future<void> pickFromCamera() => _pickImage(ImageSource.camera);

  Future<void> _pickImage(ImageSource source) async {
    if (state.isPickingImage || state.isSaving) return;
    emit(state.copyWith(isPickingImage: true));

    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) {
        emit(state.copyWith(isPickingImage: false));
        return;
      }
      emit(
        state.copyWith(
          localImagePath: file.path,
          isPickingImage: false,
          isDirty: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isPickingImage: false));
      _effects.add(
        EditProfileErrorEffect(
          source == ImageSource.camera
              ? 'Could not open the camera. Check permissions and try again.'
              : 'Could not open your photo library. Check permissions and try again.',
        ),
      );
    }
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(isSaving: true));

    final user = cachedUser;
    if (user == null) {
      emit(state.copyWith(isSaving: false));
      _effects.add(const EditProfileErrorEffect('No signed-in user found.'));
      return;
    }

    final fullName = state.fullName.isNotEmpty ? state.fullName : user.name;
    final email = state.email.trim();

    try {
      if (state.password.trim().isNotEmpty) {
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser == null) {
          throw Exception('You need to be signed in to change your password.');
        }
        await authUser.updatePassword(state.password.trim());
      }

      var avatarUrl = state.avatarUrl;
      final localPath = state.localImagePath;
      if (localPath != null && localPath.isNotEmpty) {
        avatarUrl = await _firebase.uploadAvatar(
          userId: user.id,
          file: File(localPath),
        );
      }

      await _firebase.updateProfile(user.id, {
        'name': fullName,
        'email': email,
        'avatarUrl': avatarUrl,
        'username': state.username.trim(),
        'phoneNumber': state.phoneNumber.trim(),
      });

      cachedUser = UserModel(
        id: user.id,
        name: fullName,
        email: email,
        provider: user.provider,
        avatarUrl: avatarUrl,
        age: user.age,
        favoriteGenres: user.favoriteGenres,
        level: user.level,
        title: user.title,
        stats: user.stats,
        badges: user.badges,
        streakData: user.streakData,
        createdAt: user.createdAt,
        lastReadDate: user.lastReadDate,
      );
      await persistCachedUser();

      emit(
        state.copyWith(
          isSaving: false,
          isDirty: false,
          password: '',
          avatarUrl: avatarUrl,
          clearLocalImage: true,
        ),
      );
      _effects.add(const EditProfileSavedEffect());
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isSaving: false));
      _effects.add(
        EditProfileErrorEffect(
          e.code == 'requires-recent-login'
              ? 'Please sign in again before changing your password.'
              : (e.message ?? 'Could not update password.'),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false));
      _effects.add(EditProfileErrorEffect(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}

EditProfileCubit createEditProfileCubit() =>
    EditProfileCubit(getIt.get<ProfileFirebaseService>());
