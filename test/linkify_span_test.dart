import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:linkfy_text/src/model/link.dart';

void main() {
  group('linkifySpan', () {
    const linkStyle = TextStyle(color: Color(0xFF0000FF));
    const types = [LinkType.url, LinkType.email, LinkType.phone];

    List<TextSpan> linksOf(TextSpan span) => (span.children ?? const [])
        .whereType<TextSpan>()
        .where((child) => child.recognizer != null)
        .toList();

    test('returns the text as is when there is no link', () {
      final span = linkifySpan('hello world', linkTypes: types);
      expect(span.text, 'hello world');
      expect(span.children, isNull);
    });

    test('returns an empty span for an empty text', () {
      final span = linkifySpan('', linkTypes: types);
      expect(span.toPlainText(), '');
    });

    test('keeps the plain text and splits out styled links', () {
      const text =
          'see https://example-site.com/a?b=1 or mail dev@gmail.com, tel 03-1234-5678';
      final span = linkifySpan(
        text,
        linkTypes: types,
        customLinkStyles: {
          LinkType.url: linkStyle,
          LinkType.email: linkStyle,
          LinkType.phone: linkStyle,
        },
      );
      expect(span.toPlainText(), text);
      final links = linksOf(span);
      expect(
        links.map((link) => link.text),
        ['https://example-site.com/a?b=1', 'dev@gmail.com', '03-1234-5678'],
      );
      expect(links.every((link) => link.style == linkStyle), isTrue);
    });

    test('falls back to linkStyle and calls onTap with the link', () {
      final tapped = <Link>[];
      final span = linkifySpan(
        'go www.google.com now',
        linkStyle: linkStyle,
        onTap: tapped.add,
      );
      final link = linksOf(span).single;
      expect(link.style, linkStyle);
      (link.recognizer! as TapGestureRecognizer).onTap!();
      expect(tapped.single.value, 'www.google.com');
      expect(tapped.single.type, LinkType.url);
    });
  });
}
