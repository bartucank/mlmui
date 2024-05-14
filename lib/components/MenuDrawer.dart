import 'package:flutter/material.dart';

import '../models/UserDTO.dart';
import '../pages/Common/ProfileScreen.dart';
import '../service/CacheManager.dart';
import '../service/constants.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => Container(
          padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ));

  Widget buildMenuItems(BuildContext context) {
    Container c = Container(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        runSpacing: 0,
        children: [
          FutureBuilder<UserDTO?>(
            future: CacheManager.getUserDTOFromCache(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) {
                return Text("aaa");
              } else if (snapshot.hasData && snapshot.data != null) {
                return ExpansionTile(
                  leading: const Icon(Icons.person),
                  title: Text(snapshot.data!.fullName != null &&
                          snapshot.data!.fullName != ""
                      ? "Welcome ${snapshot.data!.fullName}"
                      : "Welcome ${snapshot.data!.username}"),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Profile"),
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userDTO: snapshot.data!,role: "user",),
                          ),
                        );
                      },
                    ),
                  ],
                );
              } else {
                return Text("");
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text("Book List"),
            onTap: () {
              Navigator.pushNamed(context, '/booklistforuser');
            },
          ),

          FutureBuilder<UserDTO?>(
            future: CacheManager.getUserDTOFromCache(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) {
                return Text("aaa");
              } else if (snapshot.hasData && snapshot.data != null) {
                if(snapshot.data!.role == "USER"){
                  return ListTile(
                    leading: const Icon(Icons.meeting_room_rounded),
                    title: const Text("Room Reservations"),
                    onTap: () {
                      Navigator.pushNamed(context, '/roomlistuser');
                    },
                  );
                }
                return ListTile(
                  leading: const Icon(Icons.meeting_room_rounded),
                  title: const Text("Course Management"),
                  onTap: () {
                    Navigator.pushNamed(context, '/AddCourseScreen');
                  },
                );
              } else {
                return Text("");
              }
            },
          ),


          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text("Log out"),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, '/splash');
              CacheManager.logout();
            },
          ),
          const Divider(color: Constants.mainDarkColor),
          Center(
            child: Text(
              "MLM - 2023",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return c;
  }
}
