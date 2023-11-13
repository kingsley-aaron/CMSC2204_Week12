import 'package:api_integration/Models/AuthReponse.dart';
import 'package:api_integration/Models/LoginStructure.dart';
import 'package:api_integration/Repositories/DataService.dart';
import 'package:dio/dio.dart';
import '../Models/User.dart';

const String BaseUrl = "https://cmsc2204-mobile-api.onrender.com/Auth";

class UserClient {
  final _dio = Dio(BaseOptions(baseUrl: BaseUrl));
  DataService _dataService = DataService();

  Future<AuthResponse?> Login(LoginStructure user) async {
    try {
      var response = await _dio.post("/login",
          data: {"username": user.username, "password": user.password});

      var data = response.data['data'];

      var authResponse = new AuthResponse(data['userId'], data['token']);

      if (authResponse.token != null) {
        await _dataService.AddItem("token", authResponse.token);
      }

      return authResponse;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<List<User>?> GetUsersAsync() async {
    try {
      var token = await _dataService.TryGetItem("token");
      if (await _dataService.TryGetItem("token") != null) {
        var response = await _dio.get("/GetUsers",
            options: Options(headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token"
            }));
        List<User> users = new List.empty(growable: true);

        if (response != null) {
          for (var user in response.data) {
            users.add(User(user["_id"], user["Username"], user["Password"],
                user["Email"], user["AuthLevel"]));
          }

          return users;
        }
      } else {
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<String> GetApiVersion() async {
    var response = await _dio.get("/ApiVersion");
    return response.data;
  }

  Future<String?> DeleteUsers(User user) async {
    try {
      var token = await _dataService.TryGetItem("token");
      if (token != null) {
        var response = await _dio.post("/DeleteUserById",
            data: {"id": user.ID},
            options: Options(headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token"
            }));

        if (response.data.toString().contains("deleted")) {
          return response.data;
        } else {
          return null;
        }
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<String?> CreateUser(User user) async {
    try {
      var token = await _dataService.TryGetItem("token");
      if (token != null) {
        var response = await _dio.post(
          "/AddUser",
          data: {
            "username": user.Username, // Provide a valid username
            "password": user.Password, // Provide a valid password
            "email": user.Email, // Provide a valid email
            "authLevel": user.AuthLevel,
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );

        if (response.data.toString().contains("created")) {
          return response.data;
        } else {
          return null;
        }
      }
    } catch (error) {
      print(error);
    }
    return null;
  }
}
