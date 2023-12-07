import 'package:flutter/material.dart';
import 'package:mlmui/models/UserDTO.dart';

class UserCard extends StatelessWidget {
  final UserDTO user;

  UserCard({required this.user});

  @override
  Widget build(BuildContext context) {

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      title: Text(user.fullName),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        radius: 15,
        backgroundImage: AssetImage('assets/images/default.png'),
      ),
    );

  }
}