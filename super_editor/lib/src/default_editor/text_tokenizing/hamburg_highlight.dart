import 'package:attributed_text/attributed_text.dart';
import 'package:super_editor/src/default_editor/text.dart';
import 'package:super_editor/super_editor.dart';

class HamburgHighlightPlugin extends SuperEditorPlugin {
  static const patternTagIndexKey = "textHighlightSurroundingTagPlugin";

  final HamburgHighlightRule rule;
  HamburgHighlightPlugin({
    required this.rule,
  });
}

/// A rule for a tag that surrounds text in a document.
///
/// to identify things like "[something special here]" or "```code block```"
/// or "~~strikethrough~~" or "{ }" or "()"
///
///     startPattern: the pattern that identifies the start of the tag
///     endPattern: the pattern that identifies the end of the tag
///     they can be the same pattern or different patterns
///
class HamburgHighlightRule {
  const HamburgHighlightRule({
    required this.startPattern,
    required this.endPattern,
  });

  final String startPattern;
  final String endPattern;

  bool isHighlight(String candidate) {
    int startCount = startPattern.length;
    int endCount = endPattern.length;

    // empty highlight is not a highlight
    if (candidate.length <= startCount + endCount) {
      return false;
    }

    for (int i = 0; i < startCount; i++) {
      if (candidate[i] != startPattern[i]) {
        return false;
      }
    }

    for (int i = 0; i < endCount; i++) {
      if (candidate[candidate.length - 1 - i] != endPattern[endCount - 1 - i]) {
        return false;
      }
    }

    return true;
  }
}

class HamburgHighlightAttribution extends NamedAttribution {
  const HamburgHighlightAttribution() : super("hamburgHighlight");

  @override
  bool canMergeWith(Attribution other) => other is PatternTagAttribution;

  @override
  String toString() {
    return '[HamburgHighlightAttribution]';
  }
}

class HamburgHighlight {
  HamburgHighlight({
    required this.startPattern,
    required this.endPattern,
    required this.highlight,
  });

  final String startPattern;
  final String endPattern;
  final String highlight;

  String get raw => startPattern + highlight + endPattern;

  @override
  String toString() => "[HamburgHighlight] - $raw";
}

class IndexedHamburgHighlight {
  const IndexedHamburgHighlight(
    this.highlight,
    this.nodeId,
    this.startOffset,
  );

  final HamburgHighlight highlight;
  final String nodeId;
  final int startOffset;
  DocumentPosition get start => DocumentPosition(
      nodeId: nodeId, nodePosition: TextNodePosition(offset: startOffset));

  int get endOffset => startOffset + highlight.raw.length;

  DocumentPosition get end => DocumentPosition(
      nodeId: nodeId, nodePosition: TextNodePosition(offset: endOffset));

  DocumentRange get range => DocumentRange(start: start, end: end);

  AttributedSpans computeAttributedSpans(Document doc) =>
      (doc.getNodeById(nodeId) as TextNode)
          .text
          .copyText(startOffset, endOffset - 1)
          .spans;

  SpanRange computeLeadingSpanForAttribution(
      Document document, Attribution attribution) {
    final text = (document.getNodeById(nodeId) as TextNode).text;
    if (!text.hasAttributionAt(startOffset, attribution: attribution)) {
      return SpanRange.empty;
    }

    return text.getAttributedRange({attribution}, startOffset);
  }

  @override
  String toString() =>
      "[IndexedHamburgHighlight] - '${highlight.raw}', $startOffset -> $endOffset, node: $nodeId";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexedHamburgHighlight &&
          runtimeType == other.runtimeType &&
          highlight == other.highlight &&
          nodeId == other.nodeId &&
          startOffset == other.startOffset &&
          endOffset == other.endOffset;

  @override
  int get hashCode =>
      highlight.hashCode ^
      nodeId.hashCode ^
      startOffset.hashCode ^
      endOffset.hashCode;
}

class HamburgHighlightAroundPosition {
  const HamburgHighlightAroundPosition({
    required this.indexedHamburgHighlight,
    required this.searchOffset,
  });
  final IndexedHamburgHighlight indexedHamburgHighlight;

  final int searchOffset;

  int get searchOffsetInHighlight =>
      searchOffset - indexedHamburgHighlight.startOffset;

  bool get isInsideHighlight =>
      searchOffsetInHighlight >= 0 &&
      searchOffsetInHighlight < indexedHamburgHighlight.highlight.raw.length;

  @override
  String toString() =>
      "[HamburgHighlightAroundPosition] - iHH: $indexedHamburgHighlight, searchOffset: $searchOffset";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HamburgHighlightAroundPosition &&
          runtimeType == other.runtimeType &&
          indexedHamburgHighlight == other.indexedHamburgHighlight &&
          searchOffset == other.searchOffset;

  @override
  int get hashCode => indexedHamburgHighlight.hashCode ^ searchOffset.hashCode;
}