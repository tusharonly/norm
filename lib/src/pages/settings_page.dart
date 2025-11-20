import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:norm/src/router.dart';
import 'package:norm/src/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            AppRouter.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GitHub Group
            _buildSettingsGroup(
              title: 'Links',
              children: [
                _buildSettingsTile(
                  icon: LucideIcons.shield,
                  title: 'Privacy Policy',
                  subtitle: 'Norm',
                  onTap: () => _launchUrl(
                    'https://github.com/tusharonly/norm/blob/main/PRIVACY_POLICY.md',
                  ),
                ),
                _buildSettingsTile(
                  icon: LucideIcons.bug,
                  title: 'Report an Issue',
                  subtitle: 'Help me improve the app',
                  onTap: () =>
                      _launchUrl('https://github.com/tusharonly/Norm/issues'),
                ),
                _buildSettingsTile(
                  icon: LucideIcons.github,
                  title: 'Follow on GitHub',
                  subtitle: '@tusharonly',
                  onTap: () => _launchUrl('https://github.com/tusharonly'),
                ),
                _buildSettingsTile(
                  icon: LucideIcons.twitter,
                  title: 'Follow on X (Twitter)',
                  subtitle: '@tusharghige',
                  onTap: () => _launchUrl('https://x.com/tusharghige'),
                ),
                _buildSettingsTile(
                  icon: LucideIcons.externalLink,
                  title: 'GitHub Repository',
                  subtitle: 'View source code',
                  onTap: () => _launchUrl('https://github.com/tusharonly/Norm'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Version Group
            _buildSettingsGroup(
              title: 'About',
              children: [
                _buildInfoTile(
                  icon: LucideIcons.smartphone,
                  title: 'App Version',
                  subtitle:
                      ("v${_packageInfo?.version}+${_packageInfo?.buildNumber}"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryTextColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.secondaryTextColor,
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        color: AppColors.secondaryTextColor,
        size: 16,
      ),
      onTap: () {
        onTap();
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.secondaryTextColor,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      launchUrlString(url);
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }
}
