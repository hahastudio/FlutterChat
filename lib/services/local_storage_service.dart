import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const prefApiKey = 'pref_apikey';
  static const prefOrganization = 'pref_organization';

  String get apiKey => _prefs.getString(prefApiKey) ?? '';

  set apiKey(String value) {
    _prefs.setString(prefApiKey, value);
  }

  String get organization => _prefs.getString(prefOrganization) ?? '';

  set organization(String value) {
    _prefs.setString(prefOrganization, value);
  }
}