import 'package:flutter/material.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/components/BookCard.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../components/UserCard.dart';
import '../../models/BookDTOListResponse.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';
class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}


class _BookListScreenState extends State<BookListScreen> {

  TextEditingController _nameSurnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<BookDTOListResponse> bookDTOListResponseFuture;
  @override
  void initState() {
    super.initState();
    Map<String,dynamic> request = {
    };
    bookDTOListResponseFuture = apiService.getBooksBySpecification(request);
  }

  void clear() async{
    _nameSurnameController.text = "";
    _emailController.text = "";
    _usernameController.text = "";
    Map<String,dynamic> request = {
    };
    setState(() {
      bookDTOListResponseFuture = apiService.getBooksBySpecification(request);
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });
  }

  void filter() async{
    String namesurname = "";

    if(_nameSurnameController.text != null){
      namesurname = _nameSurnameController.text;
    }


    Map<String,dynamic> request = {
      "name":namesurname,

    };
    setState(() {
      bookDTOListResponseFuture = apiService.getBooksBySpecification(request);
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });
  }
  final double _panelMinSize = 70.0;
  final double _panelMaxSize = 200;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawerLibrarian(),
      appBar: AppBar(
        backgroundColor: Color(0xffd2232a),
        title: Text('User List'),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:WeSlide(
        controller: weSlideController,
        panelMinSize: _panelMinSize,
        blur: false,
        panelMaxSize: MediaQuery.of(context).size.height / 2,
        overlayColor:Colors.black,
        blurColor : Colors.black,
        blurSigma: 2,
        backgroundColor : Colors.white,
        overlayOpacity:0.7,
        overlay: true,

        panel:  Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: TextField(
                  controller: _nameSurnameController,
                  obscureText: false,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    disabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    labelText: "Search by Name Surname",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Color(0x00ffffff),
                    isDense: false,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    prefixIcon: Icon(Icons.person,
                        color: Colors.black, size: 18),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TextField(
                  controller: _usernameController,
                  obscureText: false,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    disabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    labelText: "Search by Username",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Color(0x00ffffff),
                    isDense: false,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    prefixIcon: Icon(Icons.abc,
                        color: Colors.black, size: 18),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TextField(
                  controller: _emailController,
                  obscureText: false,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    disabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1),
                    ),
                    labelText: "Search by Email",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Color(0x00ffffff),
                    isDense: false,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    prefixIcon: Icon(Icons.alternate_email,
                        color: Colors.black, size: 18),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          filter();
                        },
                        color: Color(0xffd2232a),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Color(0xff808080), width: 1),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Apply Filter",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        textColor: Colors.white,
                        height: 45,
                      ),
                    ),
                    SizedBox(width: 10), // İki buton arasındaki boşluk
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          clear();
                        },
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.black, width: 1),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Clear Filter",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        textColor: Color(0xffd2232a),
                        height: 45,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ),
        panelHeader: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade800,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: _panelMinSize,
          child: Center(child: Text(
            'Filters',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),),
        ),

        body: FutureBuilder<BookDTOListResponse>(
          future: bookDTOListResponseFuture,
          builder: (context2, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              if (snapshot.error is CustomException) {
                CustomException customException = snapshot.error as CustomException;
                if (customException.message == 'NEED_LOGIN') {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message: "Session experied.",
                        textAlign: TextAlign.center,
                      ),
                    );
                    Navigator.pushReplacementNamed(context2, '/login');
                  });
                  return Text('');
                } else {
                  return Text('Error: ${customException.message}');
                }
              } else {
                return Text('Error: ${snapshot.error}');
              }
            } else {
              List<BookDTO> book = snapshot.data!.bookDTOList;
              return ListView.builder(
                itemCount: book.length,
                itemBuilder: (context2, index) {
                  return BookCard(book: book[index]);
                },
              );
            }
          },
        ),
      )
    );
  }


}

