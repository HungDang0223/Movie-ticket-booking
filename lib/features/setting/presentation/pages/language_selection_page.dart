import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildLanguageTile(
                  context,
                  title: 'English',
                  subtitle: 'English',
                  languageCode: 'en',
                  isSelected: state.currentLanguage == 'en',
                  onTap: () => context.read<SettingsBloc>().add(ChangeLanguage('en')),
                ),
                _buildLanguageTile(
                  context,
                  title: 'Español',
                  subtitle: 'Spanish',
                  languageCode: 'es',
                  isSelected: state.currentLanguage == 'es',
                  onTap: () => context.read<SettingsBloc>().add(ChangeLanguage('es')),
                ),
                _buildLanguageTile(
                  context,
                  title: 'Français',
                  subtitle: 'French',
                  languageCode: 'fr',
                  isSelected: state.currentLanguage == 'fr',
                  onTap: () => context.read<SettingsBloc>().add(ChangeLanguage('fr')),
                ),
                _buildLanguageTile(
                  context,
                  title: 'Deutsch',
                  subtitle: 'German',
                  languageCode: 'de',
                  isSelected: state.currentLanguage == 'de',
                  onTap: () => context.read<SettingsBloc>().add(ChangeLanguage('de')),
                ),
                _buildLanguageTile(
                  context,
                  title: 'Italiano',
                  subtitle: 'Italian',
                  languageCode: 'it',
                  isSelected: state.currentLanguage == 'it',
                  onTap: () => context.read<SettingsBloc>().add(ChangeLanguage('it')),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
} 