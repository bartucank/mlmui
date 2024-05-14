import 'package:flutter/material.dart';

import '../models/UserDTO.dart';
import '../pages/Common/ProfileScreen.dart';
import '../service/CacheManager.dart';
import '../service/constants.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
          return const CircularProgressIndicator(); // Placeholder for loading state
        } else if (snapshot.hasData && snapshot.data != null) {
          final userDTO = snapshot.data!;
          final List<Widget> menuItems = [
            ExpansionTile(
              leading: const Icon(Icons.person),
              title: Text(userDTO.fullName != null && userDTO.fullName != ""
                  ? "Welcome ${userDTO.fullName}"
                  : "Welcome ${userDTO.username}"),
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          userDTO: userDTO,
                          role: "user",
                        ),
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
          ];

          if (userDTO.role == "USER") {
            menuItems.add(
              ListTile(
                leading: const Icon(Icons.meeting_room_rounded),
                title: const Text("Room Reservations"),
                onTap: () {
                  Navigator.pushNamed(context, '/roomlistuser');
                },
              ),
            );
            menuItems.add(
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text("Courses"),
                onTap: () {
                  Navigator.pushNamed(context, '/getCoursesScreen');
                },
              ),
            );
          } else {
            menuItems.add(
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text("Course Management"),
                onTap: () {
                  Navigator.pushNamed(context, '/AddCourseScreen');
                },
              ),
            );
          }

          menuItems.add(
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text("Log out"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/splash');
                CacheManager.logout();
              },
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: menuItems,
          );
        } else {
          return const SizedBox(); // Placeholder for empty state
        }
      },
    );
  }
}
