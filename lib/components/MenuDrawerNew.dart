import 'package:flutter/material.dart';
import '../models/UserDTO.dart';
import '../pages/Common/ProfileScreen.dart';
import '../service/CacheManager.dart';
import '../service/constants.dart';

class MenuDrawerNew extends StatelessWidget {
  final Function? onDrawerItemTap;

  MenuDrawerNew({ this.onDrawerItemTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            buildMenuItems(context),
            const Divider(color: Constants.mainDarkColor),
            Center(
              child: Text(
                "MLM - 2023",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return FutureBuilder<UserDTO?>(
      future: CacheManager.getUserDTOFromCache(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Text("Loading..."),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return Column(
            children: [
              ExpansionTile(
                leading: const Icon(Icons.person),
                title: Text(user.fullName != null && user.fullName != ""
                    ? "Welcome ${user.fullName}"
                    : "Welcome ${user.username}"),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Profile"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userDTO: user, role: "user"),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text("Book List"),
                onTap: () {
                  Navigator.pushNamed(context, '/booklistforuser');
                },
              ),
              if (user.role == "USER")
                ListTile(
                  leading: const Icon(Icons.meeting_room_rounded),
                  title: const Text("Room Reservations"),
                  onTap: () {
                    Navigator.pushNamed(context, '/roomlistuser');
                  },
                ),
              if (user.role != "USER")
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text("Course Management"),
                  onTap: () {
                    Navigator.pushNamed(context, '/AddCourseScreen');
                  },
                ),
              if (user.role == "USER")
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text("Courses"),
                  onTap: () {
                    Navigator.pushNamed(context, '/getCoursesScreen');
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text("Log out"),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/splash');
                  CacheManager.logout();
                },
              ),
            ],
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Text("User data not available"),
          );
        }
      },
    );
  }
}
