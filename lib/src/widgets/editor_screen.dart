import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'dart:async' show Completer;
import 'dart:io' show Platform;
import 'dart:typed_data' show Uint8List;

// Conditional imports for clipboard functionality
import 'package:super_clipboard/super_clipboard.dart'
    if (dart.library.js_interop) 'package:pasteboard/pasteboard.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late QuillController _controller;
  late QuillEditor _editor;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    // Initialize the Quill controller with an empty document
    _controller = QuillController.basic();

    // Initialize focus node and scroll controller
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    // Create the Quill editor widget
    _editor = QuillEditor(
      controller: _controller,
      scrollController: _scrollController,
      focusNode: _focusNode,
      config: QuillEditorConfig(
        placeholder: 'Type something or paste an image...',
        embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill Image Paste Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.paste),
            onPressed: _handlePaste,
          ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              showBoldButton: true,
              showItalicButton: true,
              showStrikeThrough: true,
              showUnderLineButton: true,
              showListBullets: true,
              showListNumbers: true,
              showIndent: true,
              showUndo: false,
              showRedo: false,
              showFontFamily: false,
              showFontSize: false,
              showInlineCode: false,
              showSubscript: false,
              showSuperscript: false,
              showSmallButton: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: false,
              showDirection: false,
              showLineHeightButton: false,
              showHeaderStyle: false,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showLink: false,
              showSearchButton: false,
              showClipboardCut: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _editor,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleInsertImage,
        child: const Icon(Icons.image),
      ),
    );
  }

  /// Handles the paste action from the app bar
  Future<void> _handlePaste() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // For mobile platforms, try to use quill_native_bridge for rich text paste
      try {
        // Check if the feature is supported
        final isSupported = await QuillNativeBridge()
            .isSupported(QuillNativeBridgeFeature.getClipboardHtml);
        if (isSupported) {
          final html = await QuillNativeBridge().getClipboardHtml();
          if (html != null) {
            // If we got HTML content, we could insert it
            // For simplicity, we'll just insert plain text
            final plainText = await QuillNativeBridge().getClipboardHtml();
            if (plainText != null) {
              _controller.replaceText(
                _controller.selection.baseOffset,
                0,
                plainText,
                null, // textSelection
              );
            }
            return;
          }
        }
      } catch (e) {
        // If native bridge fails, fall back to regular paste
        debugPrint('Native paste failed: $e');
      }
    }

    // For web or if native paste failed, we would use super_clipboard/pasteboard
    // Note: The conditional import makes this platform-specific
    // In a full implementation, we would handle clipboard operations here
    debugPrint('Clipboard functionality would be implemented here for web/desktop platforms');
  }

  /// Handles inserting an image via the FAB
  Future<void> _handleInsertImage() async {
    // In a real app, this might open an image picker
    // For this demo, we'll just show how to insert an image programmatically
    // You would replace this with actual image selection logic
    _insertImageFromUrl('https://picsum.photos/300/200');
  }

  /// Inserts an image into the editor from a URL
  void _insertImageFromUrl(String url) {
    final index = _controller.selection.baseOffset;
    final length = _controller.selection.extentOffset - index;

    // Create an image embed
    final imageEmbed = BlockEmbed.image(url);

    // Insert the image
    _controller.replaceText(
      index,
      length,
      imageEmbed,
      null, // textSelection
    );
  }
}