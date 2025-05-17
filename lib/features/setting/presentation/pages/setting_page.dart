import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/setting_event.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_state.dart';
import 'package:movie_tickets/injection.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../bloc/settings_bloc.dart';
import 'notification_settings_page.dart';
import 'language_selection_page.dart';

class SettingPage extends StatelessWidget {

  const SettingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(LoadSettings()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
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
                title: const Text('Settings'),
                centerTitle: true,
                elevation: 0,
              ),
              body: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  SettingsSection(
                    title: 'Account Settings',
                    children: [
                      SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Profile Information',
                        subtitle: 'Update your personal details',
                        onTap: () {
                          Navigator.pushNamed(context, '/user-info');
                        },
                      ),
                      SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () {
                          Navigator.pushNamed(context, '/change-password');
                        },
                      ),
                      SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage your notification preferences',
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
                    title: 'App Settings',
                    children: [
                      SettingsTile(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'Change app language',
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
                        icon: Icons.dark_mode_outlined,
                        title: 'Theme',
                        subtitle: state.isDarkMode ? 'Dark Mode' : 'Light Mode',
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
                    title: 'Support',
                    children: [
                      SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'Get help and support',
                        onTap: () {
                          // TODO: Navigate to help center
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Help center coming soon')),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App information and version',
                        onTap: () {
                          // TODO: Navigate to about page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('About page coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SettingsSection(
                    title: 'Account Actions',
                    children: [
                      SettingsTile(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        subtitle: 'Sign out of your account',
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
                                    context.read<SettingsBloc>().add(SignOut());
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
      ),
    );
  }
}
