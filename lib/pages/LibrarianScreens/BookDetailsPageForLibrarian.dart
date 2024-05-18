import 'dart:convert';

import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:comment_tree/data/comment.dart';
import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/EbookDTO.dart';
import 'package:mlmui/pages/UserScreens/Queue.dart';
import 'package:mlmui/service/ApiService.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import '../../components/BookCard.dart';
import '../../models/BookDTOListResponse.dart';
import '../../models/BookReviewDTO.dart';
import '../../service/constants.dart';
import 'EbookDetailsPageForLibrarian.dart';
class BookDetailsPageForLibrarian extends StatefulWidget {
  final BookDTO book;

  const BookDetailsPageForLibrarian({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailsPageForLibrarian> createState() => _BookDetailsPageForLibrarian();
}

class _BookDetailsPageForLibrarian extends State<BookDetailsPageForLibrarian> {
  double _currentRating = 0.0;
  String _comment = '';
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool isLoading = false;
  late String _base64Image;
  List<BookReviewDTO> reviews = [];
  List<BookReviewDTO> allReviews = [];
  List<BookReviewDTO> visibleReviews = [];
  int displayCount = 10;
  bool isFavorite = false;

  List<BookDTO> recommendedBookDTOList = [];

  @override
  void initState() {
    print("ahaaaaaaa");
    super.initState();
    _fetchImage();
    fetchReviews();
    fetchRecommendedBook();
    checkIfFavorite();
  }

  bool isExpanded = false;

  void fetchRecommendedBook() async {
    try {
      BookDTOListResponse response =
      await apiService.getBookRecommendationBasedOnBook(widget.book.id!);
      setState(() {
        recommendedBookDTOList.clear();
        recommendedBookDTOList.addAll(response.bookDTOList);
      });
    } catch (e) {}
  }

  Future<void> _fetchImage() async {
    try {
      String base64Image = await getImageBase64(widget.book.imageId);

      if (base64Image != "1") {
        setState(() {
          _base64Image = base64Image;
        });
      } else {
        print("Image not found");
      }
    } catch (error) {
      print("Error fetching image: $error");
    }
  }

  void fetchReviews() async {
    try {
      List<BookReviewDTO> review =
      await apiService.getBookReviewsByBookId(widget.book.id!);
      setState(() {
        allReviews = review;
        visibleReviews = allReviews.take(displayCount).toList();
      });
      print("REVIEW!!!! "+visibleReviews.length.toString());
    } catch (e) {
      print("Error! $e");
    }
  }

  void showMoreReviews() {
    setState(() {
      int newCount = visibleReviews.length + displayCount;
      visibleReviews = allReviews.take(newCount).toList();
    });
  }

  static Future<String> getImageBase64(int? imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString(imageId.toString());

    if (base64Image != null) {
      return base64Image;
    } else {
      final response = await http.get(Uri.parse(
          '${Constants.apiBaseUrl}/api/user/getImageBase64ById?id=$imageId'));

      if (response.statusCode == 200) {
        String base64 = base64Encode(response.bodyBytes);
        prefs.setString(imageId.toString(), base64);
        return base64;
      } else {
        return "1";
      }
    }
  }

  void saveReview() async {
    //Burdan saveledik cekerken user isticez
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> request = {
      "bookId": widget.book.id,
      "comment": _comment,
      "star": _currentRating,
    };

    try {
      String result = await apiService.makeReview(request);
      setState(() {
        isLoading = false;
      });
      if (result == "S") {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Success!",
            textAlign: TextAlign.center,
          ),
        );
        fetchReviews();
        Navigator.pop(context, "s");
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Error",
            textAlign: TextAlign.center,
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Unexpected Error. Please contact system administrator.",
            textAlign: TextAlign.left,
          ));
    }
  }

  void checkIfFavorite() async {
    print("sdfasdf");
    try {
      bool favStatus = await apiService.isFavorite(widget.book.id!);
      setState(() {
        isFavorite = favStatus;
      });
    } catch (e) {
      print("Error checking favorite status: $e");
    }
  }

  void toggleFavorite() async {
    if (isFavorite) {
      try {
        var result = await apiService.removeFavorite(widget.book.id!);
        if (result == "S") {
          setState(() {
            isFavorite = false;
          });
          if (result == "S") {
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Success!",
                textAlign: TextAlign.center,
              ),
            );
            fetchReviews();
            // Navigator.pop(context,"s");
          } else {
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Error",
                textAlign: TextAlign.center,
              ),
            );
          }
        }
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: "Unexpected Error. Please contact system administrator.",
              textAlign: TextAlign.left,
            ));
      }
    } else {
      try {
        var result = await apiService.addToFavorite(widget.book.id!);
        if (result == "S") {
          setState(() {
            isFavorite = true;
          });
          if (result == "S") {
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Success!",
                textAlign: TextAlign.center,
              ),
            );
            fetchReviews();
            // Navigator.pop(context,"s");
          } else {
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Error",
                textAlign: TextAlign.center,
              ),
            );
          }
        }
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: "Unexpected Error. Please contact system administrator.",
              textAlign: TextAlign.left,
            ));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (widget.book.status == 'AVAILABLE') {
              //popup
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.success(
                  message:
                  "You can borrow the book by going to the librarian :)",
                  textAlign: TextAlign.left,
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QueueUser(book: widget.book),
                ),
              );
            }
          },
          label: Text(
            widget.book.status == 'AVAILABLE'
                ? 'Available!'
                : 'Click To View Queue',
            style: const TextStyle(color: Constants.whiteColor),
          ),
          backgroundColor: Constants.mainRedColor,
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Constants.mainRedColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                    // Toggle icons
                    color: Colors.white,
                    size: 34.0),
                onPressed: toggleFavorite, // Use toggleFavorite now
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.memory(
                      height: (MediaQuery.of(context).size.height / 2.3) / 1.4,
                      base64Decode(_base64Image),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        widget.book.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
                      child: Text(
                        'by ${widget.book.author?.toUpperCase()}' ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Constants.greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Adjust the number of lines as needed
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () async {
                            await showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: SingleChildScrollView(
                                    // Make the dialog content scrollable
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              top: 50,
                                              left: 0,
                                              right: 0,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    child: InkResponse(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Form(
                                              key: _formKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(5),
                                                    child: AnimatedRatingStars(
                                                      initialRating: 0.0,
                                                      minRating: 0.0,
                                                      maxRating: 5.0,
                                                      filledColor: Colors.amber,
                                                      emptyColor: Colors.grey,
                                                      filledIcon: Icons.star,
                                                      halfFilledIcon:
                                                      Icons.star_half,
                                                      emptyIcon:
                                                      Icons.star_border,
                                                      onChanged:
                                                          (double rating) {
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (_) {
                                                              setState(() {
                                                                _currentRating =
                                                                    rating;
                                                              });
                                                              print(
                                                                  'Rating: $_currentRating');
                                                            });
                                                      },
                                                      displayRatingValue: true,
                                                      interactiveTooltips: true,
                                                      customFilledIcon:
                                                      Icons.star,
                                                      customHalfFilledIcon:
                                                      Icons.star_half,
                                                      customEmptyIcon:
                                                      Icons.star_border,
                                                      starSize: 40.0,
                                                      animationDuration:
                                                      const Duration(
                                                          milliseconds:
                                                          300),
                                                      animationCurve:
                                                      Curves.easeInOut,
                                                      readOnly: false,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(8),
                                                    child: TextFormField(
                                                      maxLines: 3,
                                                      onSaved: (val) {
                                                        _comment = (val ?? '');
                                                        print(
                                                            'Comment: $_comment');
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(8),
                                                    child: ElevatedButton(
                                                      child:
                                                      const Text('Submit'),
                                                      onPressed: () {
                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          _formKey.currentState!
                                                              .save();
                                                          saveReview();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.star,
                            color: Constants.yellowColor,
                          ),
                          label: const Text('Rate'),
                        ),

                        // For Ebook button
                        (widget.book.ebookId != null)
                            ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () async {
                            EbookDTO result_ebook = await apiService
                                .getEbook(widget.book.ebookId as int);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EbookDetailsPageForLibrarian(
                                  ebookData: result_ebook.data!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.book_online,
                            color: Constants.yellowColor,
                          ),
                          label: const Text('EBook'),
                        )
                            :
                        // If ebook==null
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: null,
                          icon: const Icon(
                            Icons.book_online,
                            color: Constants.yellowColor,
                          ),
                          label: const Text('EBook'),
                        ),
                      ],
                    ),
                    if (widget.book.description != null &&
                        widget.book.description!.isNotEmpty &&
                        widget.book.description!.length > 5)
                      Divider(
                        height: 20,
                      ),
                    if (widget.book.description != null &&
                        widget.book.description!.isNotEmpty &&
                        widget.book.description!.length > 5)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Description',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Constants.mainRedColor),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    if (widget.book.description != null &&
                        widget.book.description!.isNotEmpty &&
                        widget.book.description!.length > 5)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ReadMoreText(
                                    widget.book.description!,
                                    trimMode: TrimMode.Line,
                                    trimLines: 2,
                                    colorClickableText: Constants.mainRedColor,
                                    trimCollapsedText: 'Show more',
                                    trimExpandedText: 'Show less',
                                    moreStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.mainRedColor),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (recommendedBookDTOList.isNotEmpty)
                      Divider(
                        height: 20,
                      ),
                    if (recommendedBookDTOList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Recommended Books',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Constants.mainRedColor),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ), //Books
                    if (recommendedBookDTOList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(1.0, 0.0, 0, 0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          height: 140,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedBookDTOList.length,
                              itemBuilder: (context, index) {
                                if (index < recommendedBookDTOList.length) {
                                  BookDTO currentbook =
                                  recommendedBookDTOList[index];
                                  return FutureBuilder<String>(
                                      future: BookCard.getImageBase64(
                                          currentbook.imageId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return const Text('');
                                        } else {
                                          String base64Image = snapshot.data!;
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookDetailsPageForLibrarian(
                                                          book: currentbook),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 140,
                                              width: 110,
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 2.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                                child: SizedBox.fromSize(
                                                  size: const Size.fromRadius(
                                                      10), // Image radius
                                                  child: Stack(
                                                    alignment:
                                                    Alignment.bottomCenter,
                                                    children: <Widget>[
                                                      Image.memory(
                                                        base64Decode(
                                                            base64Image),
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double
                                                            .infinity, // Cover the card's upper part with the image
                                                      ),
                                                      BackdropFilter(
                                                        filter:
                                                        ui.ImageFilter.blur(
                                                            sigmaX: 1.0,
                                                            sigmaY: 1.0),
                                                        child: Container(
                                                          color: Constants
                                                              .mainDarkColor
                                                              .withOpacity(0.4),
                                                        ),
                                                      ),
                                                      Align(
                                                          alignment: Alignment
                                                              .bottomLeft,
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                5, 0, 0, 5),
                                                            child: Stack(
                                                              children: <Widget>[
                                                                Text(
                                                                  currentbook.name!
                                                                      .length <
                                                                      10
                                                                      ? currentbook
                                                                      .name!
                                                                      : "${currentbook.name!.substring(0, 10)}...",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                }
                                return null;
                              }),
                        ),
                      ),

                    Divider(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reviews',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.mainRedColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: visibleReviews.map((review) {
                        return Container(
                          child: CommentTreeWidget<Comment, Comment>(
                            Comment(
                              avatar: 'null',
                              userName: "Anonymous User",
                              content: review.comment ?? 'No comment',
                            ),
                            [],
                            treeThemeData: TreeThemeData(
                              lineColor: Constants.mainRedColor,
                              lineWidth: 0,
                            ),
                            avatarRoot: (context, data) => PreferredSize(
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey,
                                backgroundImage: AssetImage('assets/images/default.png'),
                              ),
                              preferredSize: Size.fromRadius(18),
                            ),
                            contentRoot: (context, data) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Given Star: ${review.star}",
                                          style: Theme.of(context).textTheme.caption!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${data.content}',
                                          style: Theme.of(context).textTheme.caption!.copyWith(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DefaultTextStyle(
                                    style: Theme.of(context).textTheme.caption!.copyWith(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          // Ekstra öğeler buraya eklenebilir
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        );
                      }).toList(),
                    )

                  ],
                ),
              ),
            ],
          ),
        ));
  }
}


