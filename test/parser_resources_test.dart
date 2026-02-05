import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:advanced_epub_reader/advanced_epub_reader.dart';

void main() {
  test('Parser populates resources map with image bytes', () async {
    // Build an in-memory EPUB as a zip archive
    final archive = Archive();

    // container.xml
    final containerXml = '''<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';
    archive.addFile(ArchiveFile('META-INF/container.xml', containerXml.length, Uint8List.fromList(containerXml.codeUnits)));

    // content.opf minimal with manifest and spine
    final opf = '''<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Test</dc:title>
    <dc:identifier id="bookid">testbook</dc:identifier>
  </metadata>
  <manifest>
    <item id="chap1" href="chapter.xhtml" media-type="application/xhtml+xml"/>
    <item id="img1" href="images/tiny.svg" media-type="image/svg+xml"/>
  </manifest>
  <spine>
    <itemref idref="chap1" />
  </spine>
</package>
''';
    archive.addFile(ArchiveFile('OEBPS/content.opf', opf.length, Uint8List.fromList(opf.codeUnits)));

    // chapter.xhtml referencing the image
    final chapter = '''<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><title>Chapter 1</title></head>
  <body>
    <p>Here is an image:</p>
    <img src="images/tiny.svg" alt="tiny" />
  </body>
</html>
''';
    archive.addFile(ArchiveFile('OEBPS/chapter.xhtml', chapter.length, Uint8List.fromList(chapter.codeUnits)));

    // add the tiny svg from test assets
    final svgBytes = await File('test/assets/tiny.svg').readAsBytes();
    archive.addFile(ArchiveFile('OEBPS/images/tiny.svg', svgBytes.length, svgBytes));

    final bytes = ZipEncoder().encode(archive)!;

    final book = EpubParserService.parseFromBytes(Uint8List.fromList(bytes));

    // The resources map should contain at least the image path with normalized slashes
    expect(book.resources.containsKey('OEBPS/images/tiny.svg') || book.resources.containsKey('images/tiny.svg'), isTrue);

    // Also ensure the bytes match the original svg bytes
    final foundKey = book.resources.keys.firstWhere((k) => k.endsWith('tiny.svg'));
    expect(book.resources[foundKey], isNotNull);
    expect(Uint8List.fromList(book.resources[foundKey]!), equals(Uint8List.fromList(svgBytes)));
  });
}
