import 'dart:convert';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/models/EbookDTO.dart';

import '../../service/constants.dart';

class EbookDetailsPage extends StatefulWidget {
  final String ebookData;

  const EbookDetailsPage({Key? key, required this.ebookData}) : super(key: key);

  @override
  State<EbookDetailsPage> createState() => _EbookDetailsPageState();
}

class _EbookDetailsPageState extends State<EbookDetailsPage> {

  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    Uint8List uint8List_ebook = base64Decode(widget.ebookData);
    _epubController = EpubController(
      // Load document
      document: EpubReader.readBook(uint8List_ebook),
      // Set start point
      epubCfi: 'epubcfi(/6/6[chapter-2]!/4/2/1612)',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Constants.whiteColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

      // Show actual chapter name in AppBar
      title: EpubViewActualChapter(
          controller: _epubController,
          builder: (chapterValue) => Text(
            'Chapter: ' + (chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? ''),
            textAlign: TextAlign.start,
          )
      ),
    ),

    // Show table of contents as endDrawer because of back arrow at left
    endDrawer: Drawer(
      child: EpubViewTableOfContents(
        controller: _epubController,
      ),
    ),
    // Show epub document
    body: EpubView(
      controller: _epubController,
    ),
  );
}
