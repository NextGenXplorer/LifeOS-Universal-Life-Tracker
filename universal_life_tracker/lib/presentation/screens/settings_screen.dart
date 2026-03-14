import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos/core/utils/app_colors.dart';
import 'package:lifeos/presentation/blocs/settings/settings_bloc.dart';
import 'package:lifeos/presentation/widgets/common/neo_glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is SettingsLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, SettingsLoaded state) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        // Settings List
        SliverToBoxAdapter(
          child: _buildSettingsSection(
            'General',
            [
              _buildSettingTile(
                'Dark Mode',
                'Use dark theme',
                Icons.dark_mode,
                trailing: Switch(
                  value: state.settings.darkMode,
                  onChanged: (_) => context.read<SettingsBloc>().add(ToggleDarkMode()),
                  activeColor: AppColors.primary,
                ),
              ),
              _buildSettingTile(
                'Notifications',
                'Enable push notifications',
                Icons.notifications,
                trailing: Switch(
                  value: state.settings.notificationsEnabled,
                  onChanged: (_) => context.read<SettingsBloc>().add(ToggleNotifications()),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: _buildSettingsSection(
            'Feedback',
            [
              _buildSettingTile(
                'Haptic Feedback',
                'Vibration on interactions',
                Icons.vibration,
                trailing: Switch(
                  value: state.settings.hapticEnabled,
                  onChanged: (_) => context.read<SettingsBloc>().add(ToggleHaptic()),
                  activeColor: AppColors.primary,
                ),
              ),
              _buildSettingTile(
                'Sound Effects',
                'Play sounds on events',
                Icons.volume_up,
                trailing: Switch(
                  value: state.settings.soundEnabled,
                  onChanged: (_) => context.read<SettingsBloc>().add(ToggleSound()),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: _buildSettingsSection(
            'Security',
            [
              _buildSettingTile(
                'Biometric Lock',
                'Use fingerprint or face ID',
                Icons.fingerprint,
                trailing: Switch(
                  value: state.settings.biometricEnabled,
                  onChanged: (_) => context.read<SettingsBloc>().add(ToggleBiometric()),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: _buildSettingsSection(
            'About',
            [
              _buildSettingTile('Version', '1.0.0', Icons.info_outline),
              _buildSettingTile('Privacy Policy', '', Icons.privacy_tip_outlined),
              _buildSettingTile('Terms of Service', '', Icons.description_outlined),
              _buildSettingTile('Open Source Licenses', '', Icons.code),
            ],
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBackground, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Customize your LifeOS experience',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          NeoGlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
