import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import '../util/string_util.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String apiKey = LocalStorageService().apiKey;
  String organization = LocalStorageService().organization;
  String apiHost = LocalStorageService().apiHost;
  String model = LocalStorageService().model;
  int historyCount = LocalStorageService().historyCount;
  String renderMode = LocalStorageService().renderMode;

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

  String getRenderModeDescription(String renderMode) {
    if (renderMode == 'markdown')
      return 'Markdown';
    if (renderMode == 'text')
      return 'Plain Text';
    return 'Unknown';
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
                  LocalStorageService().apiKey = result;
                  setState(() {
                    apiKey = result;
                  });
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
                  LocalStorageService().organization = result;
                  setState(() {
                    organization = result;
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.flight_takeoff),
                title: const Text('API Host (optional)'),
                value: Text('Access ${stripTrailingSlash(LocalStorageService().apiHost) + '/v1/chat/completions'}', style: const TextStyle(overflow: TextOverflow.ellipsis)),
                onPressed: (context) async {
                  _textFieldController.text = LocalStorageService().apiHost;
                  var result = await openStringDialog(context, 'API Host (optional)', 'URL like https://api.openai.com') ?? '';
                  LocalStorageService().apiHost = result;
                  setState(() {
                    apiHost = result;
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Manage API keys'),
                value: const Text('https://platform.openai.com/account/api-keys'),
                onPressed: (context) async {
                  await launchUrl(Uri.parse('https://platform.openai.com/account/api-keys'), mode: LaunchMode.externalApplication);
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
                        value: 'gpt-3.5-turbo-16k',
                        child: Text('gpt-3.5-turbo-16k'),
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
          ),
          SettingsSection(
            title: const Text('Appearance'),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.text_format),
                title: const Text('Render Mode'),
                value: Text(getRenderModeDescription(LocalStorageService().renderMode)),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'markdown',
                        child: Text('Markdown'),
                      ),
                      PopupMenuItem(
                        value: 'text',
                        child: Text('Plain Text'),
                      )
                    ];
                  },
                  onSelected: (value) async {
                    LocalStorageService().renderMode = value;
                    setState(() {
                      renderMode = value;
                    });
                  },
                ),
              ),
            ]
          ),
          SettingsSection(
            title: const Text('About'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.home),
                title: const Text('GitHub Project'),
                value: const Text('https://github.com/hahastudio/FlutterChat'),
                onPressed: (context) async {
                  await launchUrl(Uri.parse('https://github.com/hahastudio/FlutterChat'), mode: LaunchMode.externalApplication);
                },
              ),
            ]
          )
        ],
      ),
    );
  }
}