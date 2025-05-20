import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/setting_event.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_state.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';



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
        languageCode: settings.languageCode,
        countryCode: settings.countryCode,
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
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        
        await _repository.updateNotificationSettings(event.settings);
        
        // Just update the language without reloading everything
        emit(SettingsLoaded(
          isDarkMode: currentState.isDarkMode,
          languageCode: currentState.languageCode,
          countryCode: currentState.countryCode,
          notificationSettings: event.settings,
          userProfile: currentState.userProfile,
        ));
      } else {
        emit(SettingsLoading());
        await _repository.updateNotificationSettings(event.settings);
        add(LoadSettings());
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        
        await _repository.changeLanguage(event.languageCode, event.countryCode);
        
        // Just update the language without reloading everything
        emit(SettingsLoaded(
          isDarkMode: currentState.isDarkMode,
          languageCode: event.languageCode,
          countryCode: event.countryCode,
          notificationSettings: currentState.notificationSettings,
          userProfile: currentState.userProfile,
        ));
      } else {
        emit(SettingsLoading());
        await _repository.changeLanguage(event.languageCode, event.countryCode);
        add(LoadSettings());
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<SettingsState> emit) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        
        await _repository.changeTheme(event.isDarkMode);
        
        // Just update the language without reloading everything
        emit(SettingsLoaded(
          isDarkMode: event.isDarkMode,
          languageCode: currentState.languageCode,
          countryCode: currentState.countryCode,
          notificationSettings: currentState.notificationSettings,
          userProfile: currentState.userProfile,
        ));
      } else {
        emit(SettingsLoading());
        await _repository.changeTheme(event.isDarkMode);
        add(LoadSettings());
      }
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