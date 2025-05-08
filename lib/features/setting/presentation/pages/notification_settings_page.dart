import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildNotificationTile(
                  context,
                  title: 'Movie Reminders',
                  subtitle: 'Get notified about upcoming movies and showtimes',
                  value: state.notificationSettings['movie_reminders'] ?? true,
                  onChanged: (value) {
                    final newSettings = Map<String, bool>.from(state.notificationSettings);
                    newSettings['movie_reminders'] = value;
                    context.read<SettingsBloc>().add(UpdateNotificationSettings(newSettings));
                  },
                ),
                _buildNotificationTile(
                  context,
                  title: 'Booking Confirmations',
                  subtitle: 'Receive confirmation for your ticket bookings',
                  value: state.notificationSettings['booking_confirmations'] ?? true,
                  onChanged: (value) {
                    final newSettings = Map<String, bool>.from(state.notificationSettings);
                    newSettings['booking_confirmations'] = value;
                    context.read<SettingsBloc>().add(UpdateNotificationSettings(newSettings));
                  },
                ),
                _buildNotificationTile(
                  context,
                  title: 'Special Offers',
                  subtitle: 'Get notified about special deals and promotions',
                  value: state.notificationSettings['special_offers'] ?? true,
                  onChanged: (value) {
                    final newSettings = Map<String, bool>.from(state.notificationSettings);
                    newSettings['special_offers'] = value;
                    context.read<SettingsBloc>().add(UpdateNotificationSettings(newSettings));
                  },
                ),
                _buildNotificationTile(
                  context,
                  title: 'News and Updates',
                  subtitle: 'Stay updated with the latest movie news',
                  value: state.notificationSettings['news_updates'] ?? true,
                  onChanged: (value) {
                    final newSettings = Map<String, bool>.from(state.notificationSettings);
                    newSettings['news_updates'] = value;
                    context.read<SettingsBloc>().add(UpdateNotificationSettings(newSettings));
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

  Widget _buildNotificationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
} 