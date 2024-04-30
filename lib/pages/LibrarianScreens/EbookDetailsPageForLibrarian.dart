import 'dart:convert';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/models/EbookDTO.dart';

import '../../service/constants.dart';

class EbookDetailsPageForLibrarian extends StatefulWidget {
  final EbookDTO ebook;

  const EbookDetailsPageForLibrarian({Key? key, required this.ebook}) : super(key: key);

  @override
  State<EbookDetailsPageForLibrarian> createState() => _EbookDetailsPageForLibrarianState();
}

class _EbookDetailsPageForLibrarianState extends State<EbookDetailsPageForLibrarian> {

  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    /// Could be needed if data will be different
    /*if (widget.ebook.data != null) {
      if (widget.ebook.type == 'epub') {
        // Assuming data is base64 encoded epub file
        Uint8List uint8List_ebook = base64Decode(widget.ebook.data!);
        _epubController = EpubController(
          document: EpubDocument.openData(uint8List_ebook),
        );
      } else {
        // Handle other types if needed
      }
    } else {
      // Handle null data if needed
    }*/
    Uint8List uint8List_ebook = base64Decode(widget.ebook.data!);
    _epubController = EpubController(
      // Load document
      document: EpubReader.readBook(uint8List_ebook),

      /*document: EpubDocument.openAsset(
        widget.ebook.data as String
          ///'assets/book.epub'
      ),*/
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
