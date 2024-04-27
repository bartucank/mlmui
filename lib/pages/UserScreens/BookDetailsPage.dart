import 'dart:convert';

import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/pages/UserScreens/Queue.dart';
import 'package:mlmui/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:http/http.dart' as http;

import '../../models/BookReviewDTO.dart';
import '../../service/constants.dart';
class BookDetailsPage extends StatefulWidget {
  final BookDTO book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {

  double _currentRating = 0.0;
  String _comment = '';
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool isLoading = false;
  late String _base64Image;
  List<BookReviewDTO> reviews = [];
  List<BookReviewDTO> allReviews = [];
  List<BookReviewDTO> visibleReviews = [];
  int displayCount = 1;
  bool isFavorite = false;


  @override
  void initState() {
    super.initState();
    _fetchImage();
    fetchReviews();
    checkIfFavorite();
  }
  bool isExpanded = false;

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
      List<BookReviewDTO> review = await apiService.getBookReviewsByBookId(widget.book.id!);
      setState(() {
        allReviews = review;
        visibleReviews = allReviews.take(displayCount).toList();
      });
    } catch (e) {

      String err = e.toString() ?? "Unexpected error!";
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "err",
          textAlign: TextAlign.left,
        ),
      );
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

  void saveReview()async{//Burdan saveledik cekerken user isticez
    setState(() {
      isLoading = true;
    });
    Map<String,dynamic> request = {
      "bookId": widget.book.id,
      "comment": _comment,
      "star": _currentRating,
    };

    try{
      String result = await apiService.makeReview(request);
      setState(() {
        isLoading = false;
      });
      if(result == "S"){
        showTopSnackBar(Overlay.of(context),
          const CustomSnackBar.success(
            message: "Success!",
            textAlign: TextAlign.center,
          ),

        );
        fetchReviews();
        Navigator.pop(context,"s");
      }else{
        showTopSnackBar(Overlay.of(context),
          const CustomSnackBar.success(message: "Error",
            textAlign: TextAlign.center,
          ),
        );
      }
    }catch(e){
      print(e);
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(Overlay.of(context),
          const CustomSnackBar.error(message: "Unexpected Error. Please contact system administrator.",
            textAlign: TextAlign.left,
          )
      );
    }
  }

  void checkIfFavorite() async {
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
          if(result == "S"){
            showTopSnackBar(Overlay.of(context),
              const CustomSnackBar.success(
                message: "Success!",
                textAlign: TextAlign.center,
              ),

            );
            fetchReviews();
            // Navigator.pop(context,"s");
          }else{
            showTopSnackBar(Overlay.of(context),
              const CustomSnackBar.success(message: "Error",
                textAlign: TextAlign.center,
              ),
            );
          }
        }
      } catch(e){
        print(e);
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(Overlay.of(context),
            const CustomSnackBar.error(message: "Unexpected Error. Please contact system administrator.",
              textAlign: TextAlign.left,
            )
        );
      }
    } else {
      try {
        var result = await apiService.addToFavorite(widget.book.id!);
        if (result == "S") {
          setState(() {
            isFavorite = true;
          });
          if(result == "S"){
            showTopSnackBar(Overlay.of(context),
              const CustomSnackBar.success(
                message: "Success!",
                textAlign: TextAlign.center,
              ),

            );
            fetchReviews();
            // Navigator.pop(context,"s");
          }else{
            showTopSnackBar(Overlay.of(context),
              const CustomSnackBar.success(message: "Error",
                textAlign: TextAlign.center,
              ),
            );
          }
        }

      } catch(e){
        print(e);
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(Overlay.of(context),
            const CustomSnackBar.error(message: "Unexpected Error. Please contact system administrator.",
              textAlign: TextAlign.left,
            )
        );
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
            if(widget.book.status=='AVAILABLE'){
              //popup
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.success(
                  message: "You can borrow the book by going to the librarian :)",
                  textAlign: TextAlign.left,
                ),
              );
            }else{
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QueueUser(
                      book: widget.book),
                ),
              );
            }
          },
          label: Text(widget.book.status=='AVAILABLE'?'Available!':'Click To View Queue',style: const TextStyle(color: Constants.whiteColor),),

          backgroundColor: Constants.mainRedColor,
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Constants.whiteColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: IconButton(
                icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border, // Toggle icons
                    color: Colors.red,
                    size: 34.0
                ),
                onPressed: toggleFavorite, // Use toggleFavorite now
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: MediaQuery.of(context).size.height/2.1,
                color: Constants.whiteColor,
              ),
              Center(
                child: Column(
                  children: [
                    Image.memory(
                      height: (MediaQuery.of(context).size.height/2.3)/1.4,
                      base64Decode(_base64Image),
                    ),
                    const SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15,0,15,0),
                      child: Text(
                        widget.book.name??'N/A',
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
                      padding: const EdgeInsets.fromLTRB(15,2,15,0),
                      child: Text(
                        'by ${widget.book.author?.toUpperCase()}'??'',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Constants.greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Adjust the number of lines as needed
                      ),
                    ),
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
                              content: SingleChildScrollView( // Make the dialog content scrollable
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
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                child: InkResponse(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
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
                                                padding: const EdgeInsets.all(5),
                                                child: AnimatedRatingStars (
                                                  initialRating: 0.0,
                                                  minRating: 0.0,
                                                  maxRating: 5.0,
                                                  filledColor: Colors.amber,
                                                  emptyColor: Colors.grey,
                                                  filledIcon: Icons.star,
                                                  halfFilledIcon: Icons.star_half,
                                                  emptyIcon: Icons.star_border,
                                                  onChanged: (double rating) {
                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                      setState(() {
                                                        _currentRating = rating;
                                                      });
                                                      print('Rating: $_currentRating');
                                                    });
                                                  },
                                                  displayRatingValue: true,
                                                  interactiveTooltips: true,
                                                  customFilledIcon: Icons.star,
                                                  customHalfFilledIcon: Icons.star_half,
                                                  customEmptyIcon: Icons.star_border,
                                                  starSize: 40.0,
                                                  animationDuration: const Duration(milliseconds: 300),
                                                  animationCurve: Curves.easeInOut,
                                                  readOnly: false,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: TextFormField(
                                                    maxLines:3,
                                                  onSaved: (val){
                                                    _comment = (val ?? '');
                                                    print('Comment: $_comment');
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: ElevatedButton(
                                                  child: const Text('Submit'),
                                                  onPressed: () {
                                                    if (_formKey.currentState!.validate()) {
                                                      _formKey.currentState!.save();
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
                    const SizedBox(height: 20,),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    widget.book.description ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                    maxLines: isExpanded ? null : 4, // Toggle maxLines based on isExpanded
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          print("za");
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: Text(
                                        isExpanded ? 'Less' : 'More',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red, // Use the theme's primary color
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Divider(height: 20,),
                        Text(
                          'Reviews',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: visibleReviews.length + 1,
                        itemBuilder: (context, index) {
                          if (index == visibleReviews.length) {
                            return (visibleReviews.length < allReviews.length)
                                ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton(
                                onPressed: showMoreReviews,
                                child: Text(
                                  "Show More Reviews",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                ),
                              ),
                            )
                                : Container();
                          } else {
                            var review = visibleReviews[index];
                            return ListTile(
                              title: Text("Anonymous User"),
                              subtitle: Text(review.comment ?? "No comment"),
                              trailing: Text("Stars: ${review.star ?? 0}"),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}


