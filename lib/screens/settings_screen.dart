import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showUpdateEmailDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Email',
            hintText: 'Enter your new email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.updateEmail(controller.text);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Email updated' : 'Invalid email'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdatePasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter your new password',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.updatePassword(controller.text);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Password updated' : 'Password too short'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSectionHeader(context, 'Profile'),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(authProvider.username),
            subtitle: Text(authProvider.email),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Update Email'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showUpdateEmailDialog,
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Update Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showUpdatePasswordDialog,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _handleLogout,
          ),
          const Divider(height: 32),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark themes'),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.thermostat),
            title: const Text('Metric Units'),
            subtitle: Text(
              settingsProvider.metricUnits ? 'Using Celsius' : 'Using Fahrenheit',
            ),
            value: settingsProvider.metricUnits,
            onChanged: (_) => settingsProvider.toggleMetricUnits(),
          ),
          const Divider(height: 32),

          // Privacy & Notifications Section
          _buildSectionHeader(context, 'Privacy & Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive all app notifications'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (_) => settingsProvider.toggleNotifications(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.flight),
            title: const Text('Travel Alerts'),
            subtitle: const Text('Get notified about your trips'),
            value: settingsProvider.travelAlertsEnabled,
            onChanged: (_) => settingsProvider.toggleTravelAlerts(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.local_offer),
            title: const Text('Promotional Notifications'),
            subtitle: const Text('Receive special offers and discounts'),
            value: settingsProvider.promotionalNotifications,
            onChanged: (_) => settingsProvider.togglePromotionalNotifications(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.science),
            title: const Text('Beta Features'),
            subtitle: const Text('Access experimental features'),
            value: settingsProvider.betaFeaturesEnabled,
            onChanged: (_) => settingsProvider.toggleBetaFeatures(),
          ),
          const SizedBox(height: 16),

          // App Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Smart Travel Companion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}