import 'package:flutter/material.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/views/screens/settings/update_pin_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()), // Translate the title dynamically
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(
              'update_pin'.tr(context: context),
            ), // Translated text for PIN update
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UpdatePinScreen()),
              );
            },
            trailing: AppIcons.arrowForqard,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              'language_change'.tr(context: context),
            ), // Translated text for language change
            onTap: () {
              _showLanguageDialog(context);
            },
            trailing: AppIcons.arrowForqard,
          ),
        ],
      ),
    );
  }

  // Dialog to select language
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'choose_language'.tr(),
          ), // Translated text for choosing language
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  context.setLocale(Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Русский'),
                onTap: () {
                  context.setLocale(Locale('ru'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('O\'zbekcha'),
                onTap: () {
                  context.setLocale(Locale('uz'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
