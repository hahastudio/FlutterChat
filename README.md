# Flutter Chat

A new Flutter project which communicates with [OpenAI API](https://platform.openai.com/).

## Screenshots

![Screenshot 1](/document/readme_screenshot_01.png)
![Screenshot 2](/document/readme_screenshot_02.png)
![Screenshot 3](/document/readme_screenshot_03.png)
![Screenshot 4](/document/readme_screenshot_04.png)

![Screenshot tablet 1](/document/readme_screenshot_tablet_01.png)

## Features

- Support [requesting organization](https://platform.openai.com/docs/api-reference/requesting-organization)
- Support [system message](https://platform.openai.com/docs/guides/chat/introduction)
- Support [streaming message](https://platform.openai.com/docs/api-reference/chat/create#chat/create-stream) like ChatGPT
- Support to choose GPT models (gpt-3.5-turbo, gpt-3.5-turbo-16k, gpt-4, gpt-4-32k)
- Support to limit the count of conversation history when sending
- Support to show token usage in real time
- Support customized API Host
- Support tablet view

## How to use

1. Get [OpenAI API Key](https://platform.openai.com/docs/api-reference/authentication)
2. Tap setting button on top right corner to set API Key (required) and Organization (optional)
3. Add a new conversation
4. Chat with OpenAI

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

NOTE: It may take quite long time to finish build. On my MacBook Pro, it takes about 1 hour to finish.

## References

Mainly used Flutter packages:

- [shared_preferences](https://pub.dev/packages/shared_preferences) to store app settings & conversations
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management
- [settings_ui](https://pub.dev/packages/settings_ui) for setting screen
- [flutter_markdown](https://pub.dev/packages/flutter_markdown) to render messages in markdown format
- Unofficial [tiktoken](https://pub.dev/packages/tiktoken) to calculate token usage

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
