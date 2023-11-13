import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Models/User.dart';
import '../Repositories/UserClient.dart';

class UserCreationPage extends StatefulWidget {
  final UserClient userClient = UserClient();
  final VoidCallback onUserCreated;
  UserCreationPage({required this.onUserCreated, Key? key}) : super(key: key);

  @override
  State<UserCreationPage> createState() => _UserCreationPageState();
}

class _UserCreationPageState extends State<UserCreationPage> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var emailController = TextEditingController();
  var authLevelController = TextEditingController();

  bool _loading = false;
  String id = "";

  onCreateButtonPress() {
    setState(() {
      _loading = true;
      User user = User(id, usernameController.text, passwordController.text,
          emailController.text, authLevelController.text);

      widget.userClient
          .CreateUser(user)
          .then((response) => {onCreateCallCompleted(response)});
    });
  }

  void onCreateCallCompleted(var response) {
    setState(() {
      _loading = false;
    });

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User created successfully"),
        ),
      );

      Navigator.pop(context);

      widget.onUserCreated();
    } else {
      // User creation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create user"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Create User"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Enter User Information"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(hintText: "Username"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passwordController,
                          decoration: InputDecoration(hintText: "Password"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(hintText: "Email"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: authLevelController,
                          decoration:
                              InputDecoration(hintText: "Authorization Level"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: onCreateButtonPress,
                        child: Text("Create"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
