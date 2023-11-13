import 'package:api_integration/Models/AuthReponse.dart';
import 'package:api_integration/Models/LoginStructure.dart';
import 'package:api_integration/Views/usersView.dart';
import 'package:flutter/material.dart';

import 'Models/User.dart';
import 'Repositories/UserCLient.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final UserClient userClient = UserClient();

  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

bool _loading = false;

class _MyHomePageState extends State<MyHomePage> {
  String apiVersion = "";
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  void initState() {
    super.initState();
    _loading = true;

    widget.userClient
        .GetApiVersion()
        .then((reponse) => {setApiVersion(reponse)});
  }

  onLoginButtonPress() {
    setState(() {
      _loading = true;
      LoginStructure user =
          LoginStructure(usernameController.text, passwordController.text);

      widget.userClient
          .Login(user)
          .then((response) => {onLoginCallCompleted(response)});
    });
  }

  void onLoginCallCompleted(var response) {
    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failure"),
        ),
      );
    } else {
      if (response is AuthResponse) {
        getUsers();
      }
    }

    setState(() {
      _loading = false;
    });
  }

  void getUsers() {
    setState(() {
      _loading = true;
      widget.userClient
          .GetUsersAsync()
          .then((response) => onGetUsersSuccess(response));
    });
  }

  onGetUsersSuccess(List<User>? users) {
    setState(() {
      if (users != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UsersView(
                      inUsers: users,
                    )));
      }
    });
  }

  void setApiVersion(String version) {
    setState(() {
      apiVersion = version;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Enter Credentials"),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: onLoginButtonPress,
                      child: Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
            _loading
                ? Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("Loading..."),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(apiVersion),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
