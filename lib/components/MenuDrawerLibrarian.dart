import 'package:flutter/material.dart';

import '../models/UserDTO.dart';
import '../pages/Common/ProfileScreen.dart';
import '../service/CacheManager.dart';
import '../service/constants.dart';

class MenuDrawerLibrarian extends StatelessWidget {
  const MenuDrawerLibrarian({Key? key}) : super(key: key);

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
                return Text("");
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
          ExpansionTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text("User Management"),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text("User List"),
                  onTap: () {
                    Navigator.pushNamed(context, '/userlist');////////////
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: ListTile(
                  leading: const Icon(Icons.emoji_people),
                  title: const Text("Librarian List"),
                  onTap: () {
                    Navigator.pushNamed(context, '/liblist');
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: ListTile(
                  leading: const Icon(Icons.people_alt),
                  title: const Text("Lecturer List"),
                  onTap: () {
                    Navigator.pushNamed(context, '/leclist');
                  },
                ),
              ),
            ],
          ),

          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text("Book List"),
            onTap: () {
              Navigator.pushNamed(context, '/booklist');
            },
          ),

          ListTile(
            leading: const Icon(Icons.meeting_room_rounded),
            title: const Text("Room Management"),
            onTap: () {
              Navigator.pushNamed(context, '/roomLib');
            },
          ),

          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text("Copy Card Management"),
            onTap: () {
              Navigator.pushNamed(context, '/copycardmanagement');
            },
          ),

          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: const Text("Shelf Management"),
            onTap: () {
              Navigator.pushNamed(context, '/shelfmanagementscreen');
            },
          ),

          const Divider(color: Constants.mainDarkColor),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text("Log out"),
            onTap: () {
              CacheManager.logout();
              Navigator.pushReplacementNamed(context, '/splash');
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
