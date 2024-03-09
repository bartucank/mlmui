import 'package:flutter/material.dart';

import '../models/UserDTO.dart';
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
                return Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 25),
                  child: Center(
                    child: Text(snapshot.data!.fullName != null &&
                            snapshot.data!.fullName != ""
                        ? "Welcome ${snapshot.data!.fullName}"
                        : "Welcome ${snapshot.data!.username}"),
                  ),
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
                    Navigator.pushNamed(context, '/userlist');
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
            ],
          ),

          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text("Book List"),
            onTap: () {
              CacheManager.logout();
              Navigator.pushNamed(context, '/booklist');
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
