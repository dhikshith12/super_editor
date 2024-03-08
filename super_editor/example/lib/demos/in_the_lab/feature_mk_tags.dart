import 'package:example/demos/in_the_lab/in_the_lab_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class MKTagsFeatureDemo extends StatefulWidget {
  const MKTagsFeatureDemo({super.key});

  @override
  State<MKTagsFeatureDemo> createState() => _MKTagsFeatureDemoState();
}

class _MKTagsFeatureDemoState extends State<MKTagsFeatureDemo> {
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;
  late final Editor _editor;

  late final PatternTagPlugin _starTagPlugin;

  final _tags = <IndexedTag>[];

  @override
  void initState() {
    super.initState();

    _document = MutableDocument.empty();
    _composer = MutableDocumentComposer();
    _editor = Editor(
      editables: {
        Editor.documentKey: _document,
        Editor.composerKey: _composer,
      },
      requestHandlers: [
        ...defaultRequestHandlers,
      ],
    );

    _starTagPlugin = PatternTagPlugin(tagRule: TagRule.mkFormattingTagRule) //
      ..tagIndex.addListener(_updateHashTagList);
  }

  @override
  void dispose() {
    _starTagPlugin.tagIndex.removeListener(_updateHashTagList);
    super.dispose();
  }

  void _updateHashTagList() {
    setState(() {
      _tags
        ..clear()
        ..addAll(_starTagPlugin.tagIndex.getAllTags());
    });
  }

  @override
  Widget build(BuildContext context) {
    return InTheLabScaffold(
      content: _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return IntrinsicHeight(
      child: SuperEditor(
        editor: _editor,
        document: _document,
        composer: _composer,
        stylesheet: defaultStylesheet.copyWith(
          inlineTextStyler: (attributions, existingStyle) {
            TextStyle style =
                defaultInlineTextStyler(attributions, existingStyle);

            if (attributions.whereType<PatternTagAttribution>().isNotEmpty) {
              style = style.copyWith(
                color: Colors.orange,
              );
            }

            return style;
          },
          addRulesAfter: [
            ...darkModeStyles,
          ],
        ),
        documentOverlayBuilders: [
          DefaultCaretOverlayBuilder(
            caretStyle: CaretStyle().copyWith(color: Colors.redAccent),
          ),
        ],
        plugins: {
          _starTagPlugin,
        },
      ),
    );
  }
}
