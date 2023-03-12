import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String apiKey = LocalStorageService().apiKey;
  String organization = LocalStorageService().organization;

  final _textFieldController = TextEditingController();

  Future openStringDialog (BuildContext context, String title, String hintText) => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, _textFieldController.text),
            ),
          ],
        );
      }
  );

  String obscureApiKey(String apiKey) {
    if (apiKey.length < 7)
      return 'Invalid API Key';
    if (apiKey.substring(0, 3) != 'sk-')
      return 'Invalid API Key';
    return 'sk-...' + LocalStorageService().apiKey.substring(
        LocalStorageService().apiKey.length - 4, LocalStorageService().apiKey.length
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Authentication'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.key),
                title: const Text('API Key'),
                value: Text(LocalStorageService().apiKey == '' ?
                'Add your secret API key' :
                obscureApiKey(LocalStorageService().apiKey)
                ),
                onPressed: (context) async {
                  _textFieldController.text = LocalStorageService().apiKey;
                  var result = await openStringDialog(context, 'API Key', 'Open AI API Key like sk-........') ?? '';
                  if (result != '') {
                    LocalStorageService().apiKey = result;
                    setState(() {
                      apiKey = result;
                    });
                  }
                  _textFieldController.text = '';
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.group),
                title: const Text('Organization (optional)'),
                value: Text(LocalStorageService().organization == '' ?
                'None' :
                LocalStorageService().organization
                ),
                onPressed: (context) async {
                  _textFieldController.text = LocalStorageService().organization;
                  var result = await openStringDialog(context, 'Organization (optional)', 'Organization ID like org-.......') ?? '';
                  if (result != '') {
                    LocalStorageService().organization = result;
                    setState(() {
                      organization = result;
                    });
                  }
                  _textFieldController.text = '';
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}