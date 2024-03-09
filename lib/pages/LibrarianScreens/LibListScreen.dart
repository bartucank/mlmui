import 'package:flutter/material.dart';
import 'package:mlmui/models/UserDTO.dart';
import 'package:mlmui/models/UserDTOListResponse.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../components/MenuDrawerLibrarian.dart';
import '../../components/UserCard.dart';
import '../../service/ApiService.dart';
import 'package:we_slide/we_slide.dart';

import '../../service/constants.dart';

class LibListScreen extends StatefulWidget {
  const LibListScreen({Key? key}) : super(key: key);

  @override
  State<LibListScreen> createState() => _LibListScreenState();
}

class _LibListScreenState extends State<LibListScreen> {
  final listcontroller = ScrollController();
  TextEditingController _nameSurnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  WeSlideController weSlideController = WeSlideController();
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int page = -1;
  int size = 7;
  int totalPage = 1000;
  late Future<UserDTOListResponse> userDTOListResponseFuture;
  List<UserDTO> userDTOList = [];
  List<UserDTO> lastList = [];

  @override
  void initState() {
    super.initState();
    fetchMoreUsers();
    listcontroller.addListener(() {
      if(listcontroller.position.maxScrollExtent == listcontroller.offset){
        fetchMoreUsers();
      }
    });
  }
  @override
  void dispose(){
    listcontroller.dispose();
    super.dispose();
  }

  Future refresh() async {
    setState(() {
      userDTOList.clear();
    });
    page = -1;
    size = 7;
    fetchMoreUsers();
  }

  void fetchMoreUsers() async {
    if(page-1 > totalPage){
      return;
    }
    Map<String, dynamic> request = {
      "role": "LIB",
      "page": page + 1,
      "size": size,
    };

    try {
      lastList.clear();
      UserDTOListResponse response =
      await apiService.getUsersBySpecifications(request);
      setState(() {
        userDTOList.addAll(response.userDTOList);
        lastList.addAll(response.userDTOList);
        totalPage = response.totalPage;
        page++;
      });
    } catch (e) {
      print("Error! $e");
    }
  }

  void clear() async {
    _nameSurnameController.text = "";
    _emailController.text = "";
    _usernameController.text = "";
    setState(() {
      lastList.clear();
      userDTOList.clear();
      page = -1;
      size = 7;
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });

    Map<String, dynamic> request = {"role": "LIB", "page": page+1, "size": size};


    UserDTOListResponse response = await apiService.getUsersBySpecifications(request);
    setState(() {

      userDTOList.addAll(response.userDTOList);
      lastList.addAll(response.userDTOList);
      totalPage = response.totalPage;
      page++;
    });

  }

  void filter() async {
    String namesurname = "";
    String username = "";
    String email = "";

    if (_nameSurnameController.text != null) {
      namesurname = _nameSurnameController.text;
    }

    if (_usernameController.text != null) {
      username = _usernameController.text;
    }

    if (_emailController.text != null) {
      email = _emailController.text;
    }
    setState(() {
      lastList.clear();
      userDTOList.clear();
      page = -1;
      size = 7;
      weSlideController.hide();
      FocusScope.of(context).unfocus();
    });


    Map<String, dynamic> request = {
      "role": "LIB",
      "fullName": namesurname,
      "username": username,
      "email": email,
      "page": page+1,
      "size": size
    };

    UserDTOListResponse response = await apiService.getUsersBySpecifications(request);
    setState(() {

      userDTOList.addAll(response.userDTOList);
      lastList.addAll(response.userDTOList);
      totalPage = response.totalPage;
      page++;
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
          backgroundColor: Constants.mainRedColor,
          title: Text('Librarian List'),
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
          overlayColor: Constants.mainDarkColor,
          blurColor: Constants.mainDarkColor,
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
                      controller: _nameSurnameController,
                      obscureText: false,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Constants.mainDarkColor,
                      ),
                      decoration: InputDecoration(
                        disabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        labelText: "Search by Name Surname",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Constants.mainDarkColor,
                        ),
                        filled: true,
                        fillColor: Color(0x00ffffff),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon:
                        Icon(Icons.person, color: Constants.mainDarkColor, size: 18),
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
                        color: Constants.mainDarkColor,
                      ),
                      decoration: InputDecoration(
                        disabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        labelText: "Search by Username",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Constants.mainDarkColor,
                        ),
                        filled: true,
                        fillColor: Color(0x00ffffff),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon:
                        Icon(Icons.abc, color: Constants.mainDarkColor, size: 18),
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
                        color: Constants.mainDarkColor,
                      ),
                      decoration: InputDecoration(
                        disabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Constants.mainDarkColor, width: 1),
                        ),
                        labelText: "Search by Email",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Constants.mainDarkColor,
                        ),
                        filled: true,
                        fillColor: Color(0x00ffffff),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon: Icon(Icons.alternate_email,
                            color: Constants.mainDarkColor, size: 18),
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
                            color: Constants.mainRedColor,
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
                              side: BorderSide(color: Constants.mainDarkColor, width: 1),
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
                            textColor: Constants.mainRedColor,
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
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Filter'),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Invite Metuian'),
            ],
            elevation: 0,
            backgroundColor: Constants.mainRedColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.5), //Colors.grey,
            onTap: (index) {
              if(index == 0){
                weSlideController.show();
              }
            },
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
            child: userDTOList.isEmpty
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                controller: listcontroller,
                itemCount: userDTOList.length + 1,
                itemBuilder: (context2, index) {
                  if (index < userDTOList.length) {
                    UserDTO currentuser = userDTOList[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide()),
                      ),
                      child: ListTile(
                        title: UserCard(user: currentuser),
                      ),
                    );
                  } else {
                    if (!lastList.isEmpty && userDTOList.length > 7) {
                      return Padding(
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
        ));
  }
}
