import 'package:api_integration/Views/userCreation.dart';
import 'package:flutter/material.dart';

import '../Models/User.dart';
import '../Repositories/UserClient.dart';

class UsersView extends StatefulWidget {
  final List<User> inUsers;
  final UserClient userClient = UserClient();
  UsersView({Key? key, required this.inUsers}) : super(key: key);

  @override
  State<UsersView> createState() => _UsersViewState(inUsers);

  void getUsers() {}
}

bool _loading = false;

class _UsersViewState extends State<UsersView> {
  _UsersViewState(users);

  late List<User> users = widget.inUsers;

  void deleteUser(User user) {
    setState(() {
      _loading = true;

      widget.userClient
          .DeleteUsers(user)
          .then((response) => {deleteUserSuccessful(response)});
    });
  }

  deleteUserSuccessful(var response) {
    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete"),
        ),
      );
    } else {
      getUsers();
    }

    setState(() {
      _loading = false;
    });
  }

  void getUsers() {
    setState(() {
      _loading = true;
      widget.userClient.GetUsersAsync().then((newUsers) {
        setState(() {
          if (newUsers != null) {
            users = newUsers;
          }
          _loading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("View Users"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: users.map((user) {
              return Padding(
                padding: EdgeInsets.all(3),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Username: ${user.Username}"),
                        subtitle: Text("Auth Level: ${user.AuthLevel}"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {},
                            child: const Text("UPDATE"),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          TextButton(
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: Text(
                                    "Are you sure you want to delete ${user.Username}?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteUser(user);
                                      Navigator.pop(context, 'DELETE');
                                    },
                                    child: const Text('DELETE'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('DELETE'),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserCreationPage(
                  onUserCreated: getUsers,
                ),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
