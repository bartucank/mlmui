import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:mlmui/pages/UserScreens/UserHome.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mlmui/models/BookDTO.dart';
import '../../components/MenuDrawer.dart';
import '../../models/UserDTO.dart';
import '../../service/ApiService.dart';
import '../../components/OutlinedButtons.dart';
import '../../models/BookDTOListResponse.dart';
import 'dart:convert';
import 'package:mlmui/components/BookCard.dart';
import 'dart:ui' as ui;

import 'BookDetailsPage.dart';

class QueueUser extends StatefulWidget {
  final BookDTO book;
  const QueueUser({Key? key, required this.book}) : super(key: key);

  @override
  State<QueueUser> createState() => _QueueUserState();
}

class _QueueUserState extends State<QueueUser>
    with SingleTickerProviderStateMixin {
  bool _isContainerVisible = false;
  Offset offset = const Offset(120, 0);
  final double height = 200;
  final double width = 200;
  bool charactermoving = true;
  String msg = "";
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool canEnterQueue = false;
  bool showArrowBar = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _updateSize();
    });
  }

  void _updateSize() async {
    Map<String, dynamic> result = await apiService.getStatusOfBook(widget.book.id!);
    if(result['statusCode'] == 'S'){
      setState(() {
        canEnterQueue = true;
      });
    }
    setState(() {
      msg=result['msg'];
      _isContainerVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final res_width = MediaQuery.of(context).size.width;
    final res_height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 3, 19, 32),
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xffd2232a),
          title: Text('Queue'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffd2232a),
                Color(0xffffffff),
              ],
              stops: [0.2, 1],
            ),
          ),
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: FadeInLeft(
                  delay: Duration(seconds: 1),
                  child: Text("Queue Status",
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .merge(const TextStyle(
                            color: Colors.white,
                          ))),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: FlipInY(
                  duration: Duration(seconds: 1),
                  child: Text(
                      overflow: TextOverflow.fade,
                      msg,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .merge(const TextStyle(color: Colors.white))),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: _isContainerVisible ? res_height * 0.5 : 0.0,
                width: _isContainerVisible ? res_width * 0.9 : 0.0,
                curve: Curves.easeOut,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeIn,
                      right: offset.dx - (width / 2),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: res_width / 2.3,
                            child: Image.asset(
                              'assets/images/male.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onPanUpdate: (details) {
                        RenderBox getBox =
                            context.findRenderObject() as RenderBox;
                        setState(() {
                          offset = getBox.localToGlobal(details.globalPosition);
                          charactermoving = true;
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          offset = const Offset(120, 0);
                          charactermoving = false;
                        });
                      },
                      child: SizedBox(
                        height: _isContainerVisible ? res_height * 0.5 : 0,
                        child: Stack(
                          children: <Widget>[
                            AnimatedPositioned(
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                              left: offset.dx - (width / 2.3),
                              child: SizedBox(
                                width:
                                    _isContainerVisible ? res_width / 1.5 : 0,
                                height:
                                    _isContainerVisible ? res_height / 2 : 0,
                                child: Image.asset(
                                  'assets/images/female.png',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if(canEnterQueue && showArrowBar)
                Builder(
                  builder: (context) {
                    final GlobalKey<SlideActionState> _key = GlobalKey();
                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20,10,0,0),
                          child: SizedBox(
                            width: _isContainerVisible?res_width * 0.9:0,
                            child: SlideAction(
                              text: "Enter Queue",
                              textStyle: Theme.of(context).textTheme.headline6!.merge(
                                  const TextStyle(
                                      color: Color(0xffd2232a),
                                      fontWeight: FontWeight.bold)),
                              key: _key,
                              onSubmit: () async {
                                Map<String, dynamic> result = await apiService.enqueue(widget.book.id!);
                                try {
                                  if (result['statusCode'].toString().toUpperCase() == "S") {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      const CustomSnackBar.success(
                                        message: "You entered the queue :) ",
                                        textAlign: TextAlign.left,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  String msg = result['message'].toString();
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.error(
                                      message: msg,
                                      textAlign: TextAlign.left,
                                    ),
                                  );
                                }
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  setState(() {
                                    showArrowBar = false;
                                  });
                                });

                              },
                              innerColor: Color(0xffd2232a),
                              outerColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ));
  }
}
