# Flutter Quill Image Paste Demo

A minimal Flutter app that demonstrates a rich-text editor with:

- Image embeds (rendered in the editor)
- Basic formatting toolbar (bold, italic, underline, strike-through, bullets, numbering, indent)
- A 50% height editor container with a sticky "Attachment" button (UI demo)
- Mobile clipboard integration (via `quill_native_bridge`) to experiment with pasting

This project uses `flutter_quill` 11 and `flutter_quill_extensions` for image/video embeds.

## Requirements

- Flutter SDK: 3.27.x (Dart 3.6.x)
- iOS/macOS: Xcode with CocoaPods
- Android: Android Studio + SDKs

Check your Flutter version:

```bash
flutter --version
```

## Getting started

```bash
# From repo root
flutter pub get

# iOS (simulator)
flutter build ios --simulator
flutter run -d ios

# Android
flutter run -d android

# macOS (if you’ve enabled the macOS platform)
flutter config --enable-macos-desktop
flutter run -d macos
```

## Project structure

- `lib/main.dart`: App bootstrap and localization setup
- `lib/src/widgets/editor_screen.dart`: Editor screen with toolbar, embed builders, paste and image insertion hooks, and UI customizations

## Key packages

- `flutter_quill: ^11.4.2`
- `flutter_quill_extensions: ^11.0.0` (provides image/video embed builders)
- `quill_native_bridge: ^11.0.1`
- `super_clipboard: ^0.9.0` and `pasteboard: ^0.4.0` (scaffold for non-mobile clipboard; not fully wired in this demo)
- `flutter_localizations` (required for `flutter_quill` toolbars)

### Windows bridge override (important)

Pubspec includes a dependency override:

```yaml
dependency_overrides:
  quill_native_bridge_windows: 0.0.1
```

Rationale: `quill_native_bridge_windows 0.0.2` references a removed constant (`GMEM_MOVEABLE`) in newer `win32` releases. Version `0.0.1` uses the enum-based flags and compiles cleanly on non-Windows targets too. Keep this override until the upstream package updates.

## Editor setup (embeds + toolbar)

This app wires `flutter_quill_extensions` to render image embeds:

```dart
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

final editor = QuillEditor(
  controller: _controller,
  scrollController: _scrollController,
  focusNode: _focusNode,
  config: QuillEditorConfig(
    placeholder: 'Type something or paste an image...',
    embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
  ),
);
```

A minimal formatting toolbar is shown above the editor using `QuillSimpleToolbar` with only the requested buttons enabled.

## Localization (required by toolbar)

`flutter_quill` toolbars require the package’s localizations. The app sets:

```dart
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;

MaterialApp(
  localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
  supportedLocales: FlutterQuillLocalizations.supportedLocales,
  // ...
);
```

And `pubspec.yaml` includes:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

If you forget this, you’ll see `MissingFlutterQuillLocalizationException` when using toolbar buttons like Indent.

## UI customization in this demo

- The editor is wrapped in a `Container` set to 50% of the screen height with rounded borders.
- A sticky footer with an `Attachment` button is overlaid at the bottom of that container using a `Stack`. It’s a no-op button intended to demonstrate how to add persistent UI.

## Pasting and image embeds

- Mobile (Android/iOS): The demo attempts to use `quill_native_bridge` to access HTML from the clipboard (see `_handlePaste()` in `editor_screen.dart`). For simplicity, it currently inserts plain text if HTML is present.
- Non-mobile: The code contains a conditional import for `super_clipboard`/`pasteboard`, but the paste logic is intentionally stubbed to keep the example focused.

Programmatic image insertion example used in this demo:

```dart
_controller.replaceText(
  index,
  length,
  BlockEmbed.image('https://picsum.photos/300/200'),
  null,
);
```

Because `flutter_quill_extensions` is configured, `image` embeds render correctly.

## Troubleshooting

- GMEM_MOVEABLE error (Windows bridge)
  - Keep the `quill_native_bridge_windows: 0.0.1` dependency override as provided in `pubspec.yaml`.
- Missing localization exception
  - Ensure `FlutterQuillLocalizations.localizationsDelegates` and `FlutterQuillLocalizations.supportedLocales` are set on your `MaterialApp` and `flutter_localizations` is in `pubspec.yaml`.
- Images not rendering
  - Verify `flutter_quill_extensions` is installed and that `embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders()` is passed to `QuillEditorConfig`.
- iOS CocoaPods issues
  - Try: `flutter clean && flutter pub get && cd ios && pod repo update && pod install && cd ..`.
- Paste not working on desktop/web
  - The demo logs a message instead of fully implementing desktop/web clipboard. You can wire `super_clipboard` to handle rich content and images per your requirements.

## Extending this demo

- Convert pasted HTML to Delta to preserve formatting.
- Upload images to a backend and insert the returned URLs.
- Add more toolbar buttons (headers, colors, alignment, code block, etc.).
- Implement a real attachment flow (picker + upload + embed/custom block).

## License

MIT (or match your repository’s license).
