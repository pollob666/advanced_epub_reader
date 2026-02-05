import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:advanced_epub_reader/advanced_epub_reader.dart';

void main() {
  testWidgets('EpubContentBuilder renders SVG and PNG from resources', (WidgetTester tester) async {
    // Prepare tiny SVG and PNG bytes
    final svgBytes = Uint8List.fromList(await File('test/assets/tiny.svg').readAsBytes());
    final pngBytes = Uint8List.fromList(await File('test/assets/tiny.png').readAsBytes());

    // resources map
    final resources = {
      'OEBPS/images/tiny.svg': svgBytes,
      'OEBPS/images/tiny.png': pngBytes,
    };

    // HTML content referencing the SVG and PNG
    final html = '<p>SVG:</p><img src="OEBPS/images/tiny.svg" /><p>PNG:</p><img src="OEBPS/images/tiny.png" />';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EpubContentBuilder.buildContentWithFont(
          'Arial',
          14.0,
          1.4,
          html,
          ThemeManager.getCurrentTheme(),
          null,
          resources: resources,
          chapterFilePath: 'OEBPS/chapter.xhtml',
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Expect an SvgPicture to be found for the inline SVG
    expect(find.byType(SvgPicture), findsOneWidget);

    // Expect an Image widget for the PNG (may find multiple Images, so at least one)
    expect(find.byType(Image), findsWidgets);
  });
}
