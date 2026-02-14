import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

class CustomAboutDialog extends StatefulWidget {
  final ThemeConfig currentTheme;
  final AppLocalizations localizations;

  const CustomAboutDialog({
    Key? key,
    required this.currentTheme,
    required this.localizations,
  }) : super(key: key);

  @override
  _CustomAboutDialogState createState() => _CustomAboutDialogState();
}

class _CustomAboutDialogState extends State<CustomAboutDialog> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.currentTheme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        widget.localizations.appName,
        style: TextStyle(
          color: widget.currentTheme.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Version $_version',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _buildLink(
              icon: Icons.policy,
              text: 'Privacy Policy',
              onTap: () => _launchURL('https://github.com/mcanererdem/zikirmatik/blob/main/PRIVACY_POLICY.md'),
            ),
            const SizedBox(height: 10),
            _buildLink(
              icon: Icons.code,
              text: 'Source Code on GitHub',
              onTap: () => _launchURL('https://github.com/mcanererdem/zikirmatik'),
            ),
            const SizedBox(height: 10),
            _buildLink(
              icon: Icons.person,
              text: 'Developer: M. Caner Erdem',
              onTap: () => _launchURL('https://github.com/mcanererdem'),
            ),
            const SizedBox(height: 20),
            Text(
              '© ${DateTime.now().year} Zikirmatik. All rights reserved.',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            widget.localizations.ok,
            style: TextStyle(color: widget.currentTheme.accentColor),
          ),
  
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildLink({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: widget.currentTheme.accentColor, size: 20),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
