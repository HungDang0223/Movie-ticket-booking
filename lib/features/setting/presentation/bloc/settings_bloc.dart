import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateProfile extends SettingsEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfile(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

class ChangePassword extends SettingsEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword(this.currentPassword, this.newPassword);

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class UpdateNotificationSettings extends SettingsEvent {
  final Map<String, bool> settings;

  const UpdateNotificationSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ChangeLanguage extends SettingsEvent {
  final String languageCode;

  const ChangeLanguage(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class ChangeTheme extends SettingsEvent {
  final bool isDarkMode;

  const ChangeTheme(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class SignOut extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool isDarkMode;
  final String currentLanguage;
  final Map<String, bool> notificationSettings;
  final UserProfile userProfile;

  const SettingsLoaded({
    required this.isDarkMode,
    required this.currentLanguage,
    required this.notificationSettings,
    required this.userProfile,
  });

  @override
  List<Object?> get props => [isDarkMode, currentLanguage, notificationSettings, userProfile];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangePassword>(_onChangePassword);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeTheme>(_onChangeTheme);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(
        isDarkMode: settings.isDarkMode,
        currentLanguage: settings.currentLanguage,
        notificationSettings: settings.notificationSettings,
        userProfile: settings.userProfile,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await _repository.updateProfile(event.profileData);
      add(LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangePassword(ChangePassword event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await _repository.changePassword(event.currentPassword, event.newPassword);
      add(LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateNotificationSettings(UpdateNotificationSettings event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await _repository.updateNotificationSettings(event.settings);
      add(LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await _repository.changeLanguage(event.languageCode);
      add(LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await _repository.changeTheme(event.isDarkMode);
      add(LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await _repository.signOut();
      emit(SettingsInitial());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
} 