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
  String model = LocalStorageService().model;
  int historyCount = LocalStorageService().historyCount;

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
                value: Text(LocalStorageService().apiKey == ''
                  ? 'Add your secret API key'
                  : obscureApiKey(LocalStorageService().apiKey)
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
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.group),
                title: const Text('Organization (optional)'),
                value: Text(LocalStorageService().organization == ''
                  ? 'None'
                  : LocalStorageService().organization
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
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Chat Parameters'),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.view_in_ar),
                title: const Text('Model'),
                value: Text(LocalStorageService().model),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'gpt-3.5-turbo',
                        child: Text('gpt-3.5-turbo'),
                      ),
                      PopupMenuItem(
                        value: 'gpt-4',
                        child: Text('gpt-4'),
                      ),
                      PopupMenuItem(
                        value: 'gpt-4-32k',
                        child: Text('gpt-4-32k'),
                      )
                    ];
                  },
                  onSelected: (value) async {
                    LocalStorageService().model = value;
                    setState(() {
                      model = value;
                    });
                  },
                ),
              ),
              SettingsTile(
                leading: const Icon(Icons.history),
                title: const Text('History Limit'),
                value: Text(LocalStorageService().historyCount.toString()),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: '0',
                        child: Text('0'),
                      ),
                      PopupMenuItem(
                        value: '2',
                        child: Text('2'),
                      ),
                      PopupMenuItem(
                        value: '4',
                        child: Text('4'),
                      ),
                      PopupMenuItem(
                        value: '6',
                        child: Text('6'),
                      ),
                      PopupMenuItem(
                        value: '8',
                        child: Text('8'),
                      ),
                      PopupMenuItem(
                        value: '10',
                        child: Text('10'),
                      )
                    ];
                  },
                  onSelected: (value) async {
                    int intValue = int.parse(value);
                    LocalStorageService().historyCount = intValue;
                    setState(() {
                      historyCount = intValue;
                    });
                  },
                ),
              ),
            ]
          )
        ],
      ),
    );
  }
}