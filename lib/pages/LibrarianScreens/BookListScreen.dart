import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/components/BookCard.dart';
import '../../components/MenuDrawerLibrarian.dart';
import '../../components/UserCard.dart';
import '../../models/BookCategoryEnumDTO.dart';
import '../../models/BookCategoryEnumDTOListResponse.dart';
import '../../models/BookDTOListResponse.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../components/MenuDrawerLibrarian.dart';
import '../../components/UserCard.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final listcontroller = ScrollController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int page = -1;
  int size = 7;
  int totalPage = 1000;
  late Future<BookDTOListResponse> bookDTOListResponseFuture;
  List<BookDTO> bookDTOList = [];
  List<BookDTO> lastList = [];
  List<BookCategoryEnumDTO> _dropdownItems = [];
  BookCategoryEnumDTO? _selectedValue;

  Map<String, dynamic> globalFilterRequest = {};

  void fetchCategories() async {
    try {
      BookCategoryEnumDTOListResponse response =
      await apiService.getBookCategoryEnumDTOListResponse();
      setState(() {
        _dropdownItems.addAll(response.list);
      });
    } catch (e) {
      print("Error! $e");
    }
  }
  @override
  void initState() {
    super.initState();
    fetchFirstBooks();
    _dropdownItems.insert(0, BookCategoryEnumDTO("ANY", 'ANY'));
    fetchCategories();
    listcontroller.addListener(() {
      if (listcontroller.position.maxScrollExtent == listcontroller.offset) {
        fetchMoreBook();
      }
    });
  }
  @override
  void dispose() {
    listcontroller.dispose();
    super.dispose();
  }

  Future refresh() async {
    setState(() {
      bookDTOList.clear();
    });
    page = -1;
    size = 7;
    fetchFirstBooks();
  }

  void fetchMoreBook() async {
    if (page - 1 > totalPage) {
      return;
    }
    globalFilterRequest['page'] = globalFilterRequest['page'] +1;

    try {
      lastList.clear();
      BookDTOListResponse response =
      await apiService.getBooksBySpecification(globalFilterRequest);
      setState(() {
        bookDTOList.addAll(response.bookDTOList);
        lastList.addAll(response.bookDTOList);
        totalPage = response.totalPage;
        page++;
      });
    } catch (e) {
      print("Error! $e");
    }
  }


  void fetchFirstBooks() async {
    if (page - 1 > totalPage) {
      return;
    }
    Map<String, dynamic> request = {
      "page": page + 1,
      "size": size,
    };
    setState(() {
      globalFilterRequest = request;
    });

    try {
      lastList.clear();
      BookDTOListResponse response =
      await apiService.getBooksBySpecification(request);
      setState(() {
        bookDTOList.addAll(response.bookDTOList);
        lastList.addAll(response.bookDTOList);
        totalPage = response.totalPage;
        page++;
      });
    } catch (e) {
      print("Error! $e");
    }
  }


  void clear() async {
    _titleController.text = "";
    _categoryController.text = "";
    _authorController.text = "";
    setState(() {
      lastList.clear();
      bookDTOList.clear();
      page = -1;
      size = 7;
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });

    Map<String, dynamic> request = {"page": page + 1, "size": size};

    setState(() {
      globalFilterRequest = request;
    });
    BookDTOListResponse response =
    await apiService.getBooksBySpecification(request);
    setState(() {
      bookDTOList.addAll(response.bookDTOList);
      lastList.addAll(response.bookDTOList);
      totalPage = response.totalPage;
      page++;
    });
  }

  void filter() async {
    String name = _titleController.text ?? "";
    String author = _authorController.text ?? "";

    setState(() {
      lastList.clear();
      bookDTOList.clear();
      page = -1;
      size = 7;
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });

    Map<String, dynamic> request = {
      'name': name,
      'author': author,
      'page': page + 1,
      'size': size,
    };

    setState(() {
      globalFilterRequest = request;
    });
    if (_selectedValue != null && _selectedValue?.enumValue != "ANY") {
      // Include category parameter only if a specific category is chosen
      request['category'] = _selectedValue?.enumValue;
    }

    try {
      BookDTOListResponse response =
      await apiService.getBooksBySpecification(request);

      setState(() {
        bookDTOList.addAll(response.bookDTOList);
        lastList.addAll(response.bookDTOList);
        totalPage = response.totalPage;
        page++;
      });
    } catch (e) {
      print("Error! $e");
    }
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
          title: Text('Book List'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: WeSlide(
          controller: weSlideController,
          panelMinSize: _panelMinSize,
          blur: false,
          panelMaxSize: MediaQuery.of(context).size.height / 2,
          overlayColor: Colors.black,
          blurColor: Colors.black,
          blurSigma: 2,
          backgroundColor: Colors.white,
          overlayOpacity: 0.7,
          overlay: true,
          panel: Container(
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
                      controller: _titleController,
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
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        labelText: "Search by Title",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        filled: true,
                        fillColor: Color(0x00ffffff),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon:
                        Icon(Icons.person, color: Colors.black, size: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: TextField(
                      controller: _authorController,
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
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        labelText: "Search by Author",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        filled: true,
                        fillColor: Color(0x00ffffff),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon:
                        Icon(Icons.abc, color: Colors.black, size: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: DropdownButtonFormField<BookCategoryEnumDTO>(
                      value: _selectedValue,
                      onChanged: (value) {
                        setState(() {
                          _selectedValue = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Search by Category",
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
                          vertical: 8,
                          horizontal: 12,
                        ),
                        prefixIcon: Icon(Icons.alternate_email, color: Colors.black, size: 18),
                        border: OutlineInputBorder(  // Add this line to define a border
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      items: _dropdownItems.map((category) {
                        return DropdownMenuItem<BookCategoryEnumDTO>(
                          value: category,
                          child: Row(
                            children: [
                              SizedBox(width: 8),
                              Text(category.enumValue),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                              side: BorderSide(
                                  color: Color(0xff808080), width: 1),
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
              )),
          footer: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Filter'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add), label: 'Add New Book'),
            ],
            elevation: 0,
            backgroundColor: Color(0xffd2232a),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            //Colors.grey,
            onTap: (index) {
              if (index == 0) {
                weSlideController.show();
              }
              if(index == 1){
                Navigator.pushNamed(context, "/bookcreate");
              }
            },
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
            child: bookDTOList.isEmpty
                ? Text("")
                : RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      controller: listcontroller,
                      itemCount: bookDTOList.length + 1,
                      itemBuilder: (context2, index) {
                        if (index < bookDTOList.length) {
                          BookDTO currentbook = bookDTOList[index];
                          return Slidable(
                              startActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    backgroundColor: Colors.blue,
                                    icon: Icons.edit,
                                    label: 'Update',
                                    onPressed: (context) => dissmissed(),
                                  )
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    backgroundColor: Colors.green,
                                    icon: Icons.send,
                                    label: 'Borrow',
                                    onPressed: (context) => dissmissed(),
                                  )
                                ],
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide()),
                                ),
                                child: ListTile(
                                  title: BookCard(book: currentbook),
                                ),
                              ));
                        } else {
                          if (!lastList.isEmpty && bookDTOList.length > 7) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        }
                      },
                    ),
                  ),
          ),
        )
    );
  }
}

void dissmissed() {}
