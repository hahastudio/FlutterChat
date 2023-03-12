# Flutter Chat

A new Flutter project which communicates with [OpenAI API](https://platform.openai.com/).

## Screenshots

![Screenshot 1](/document/readme_screenshot_01.png)
![Screenshot 2](/document/readme_screenshot_02.png)

### Architecture

It uses [Flutter framework](https://flutter.dev/), and uses [BLoC pattern](https://pub.dev/packages/flutter_bloc) to implement state management.

## How to build

Get Flutter package:

```
flutter pub get
```

Build apk:

```
flutter build apk
```

## References

Mainly used Flutter packages:

- [shared_preferences](https://pub.dev/packages/shared_preferences) to store app settings & conversations
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management
- [settings_ui](https://pub.dev/packages/settings_ui) for setting page
- [flutter_spinkit](https://pub.dev/packages/flutter_spinkit) to show a fancy loading indicators

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
