# Flutter Chat

A new Flutter project which communicates with [OpenAI API](https://platform.openai.com/).

## Screenshots

![Screenshot 1](/document/readme_screenshot_01.png)
![Screenshot 2](/document/readme_screenshot_02.png)
![Screenshot 3](/document/readme_screenshot_03.png)
![Screenshot 4](/document/readme_screenshot_04.png)

## Features

- Support [requesting organization](https://platform.openai.com/docs/api-reference/requesting-organization)
- Support [system message](https://platform.openai.com/docs/guides/chat/introduction)
- Support [streaming message](https://platform.openai.com/docs/api-reference/chat/create#chat/create-stream) like ChatGPT
- Support to choose GPT models (gpt-3.5-turbo, gpt-4, gpt-4-32k)

## How to use

1. Get [OpenAI API Key](https://platform.openai.com/docs/api-reference/authentication)
2. Tap setting button on top right corner to set API Key (required) and Organization (optional)
3. Add a new conversation
4. Chat with Open AI

## Architecture

It uses [Flutter framework](https://flutter.dev/), and uses [BLoC pattern](https://bloclibrary.dev/) to implement state management.

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
- [flutter_markdown](https://pub.dev/packages/flutter_markdown) to render messages in markdown format

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
