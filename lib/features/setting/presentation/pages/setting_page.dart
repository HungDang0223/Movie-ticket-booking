import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/core/utils/app_localizations.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/setting_event.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_state.dart';
import 'package:movie_tickets/injection.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../bloc/settings_bloc.dart';
import 'notification_settings_page.dart';
import 'language_selection_page.dart';

class SettingPage extends StatefulWidget {

  const SettingPage({
    super.key,
  });

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late final SettingsBloc bloc;
  @override
  void initState() {
    bloc.add(LoadSettings());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
    
        if (state is SettingsError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${state.message}'),
            ),
          );
        }
    
        if (state is SettingsLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text('settings.settings'.i18n()),
              centerTitle: true,
              elevation: 0,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SettingsSection(
                  title: 'settings.accountSettings'.i18n(),
                  children: [
                    SettingsTile(
                      icon: Icons.person_outline,
                      title: 'settings.profileInformation'.i18n(),
                      onTap: () {
                        Navigator.pushNamed(context, '/user-info');
                      },
                    ),
                    SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'settings.changePassword'.i18n(),
                      
                      onTap: () {
                        Navigator.pushNamed(context, '/change-password');
                      },
                    ),
                    SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'settings.notifications'.i18n(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationSettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SettingsSection(
                  title: 'settings.appSettings'.i18n(),
                  children: [
                    SettingsTile(
                      icon: Icons.language,
                      title: AppLocalizations.translate(context, 'settings.language'),
                      
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSelectionPage(),
                          ),
                        );
                      },
                    ),
                    SettingsTile(
                      icon: state.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      title: 'settings.theme'.i18n(),
                      onTap: () {
                        context.read<SettingsBloc>().add(ChangeTheme(!state.isDarkMode));
                      },
                      trailing: Switch(
                        value: state.isDarkMode,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(ChangeTheme(value));
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SettingsSection(
                  title: 'settings.helpCenter'.i18n(),
                  children: [
                    SettingsTile(
                      icon: Icons.help_outline,
                      title: 'settings.helpCenter'.i18n(),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('settings.comingSoon'.i18n(),), duration: Duration(milliseconds: 300)),
                        );
                      },
                    ),
                    SettingsTile(
                      icon: Icons.info_outline,
                      title: 'settings.about'.i18n(),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('settings.comingSoon'.i18n()), duration: Duration(milliseconds: 300),),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SettingsSection(
                  title: 'settings.accountActions'.i18n(),
                  children: [
                    SettingsTile(
                      icon: Icons.logout,
                      title: 'settings.signOut'.i18n(),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  bloc.add(SignOut());
                                  Navigator.pop(context);
                                  // TODO: Navigate to login page
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Signing out...')),
                                  );
                                },
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );
                      },
                      textColor: Colors.red,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
    
        return const Scaffold(
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      },
    );
  }
}
