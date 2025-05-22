import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/setting_event.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_state.dart';
import '../bloc/settings_bloc.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.selectLanguage'.i18n()),
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
                  title: 'Tiếng Việt',
                  languageCode: 'vi',
                  isSelected: state.languageCode == 'vi',
                  onTap: () {
                    context.read<SettingsBloc>().add(const ChangeLanguage('vi', 'VN'));
                  },
                ),
                _buildLanguageTile(
                  context,
                  title: 'English',
                  languageCode: 'en',
                  isSelected: state.languageCode == 'en',
                  onTap: () {
                    context.read<SettingsBloc>().add(const ChangeLanguage('en', 'US'));
                  },
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