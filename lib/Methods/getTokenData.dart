import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();
Future<String> getName() async {
  // Replace 'userName' with the key you used to store the name in secure storage
  String? name = await secureStorage.read(key: 'name') ?? '';
  return name;
}

Future<String> getId() async {
  // Replace 'userName' with the key you used to store the name in secure storage
  String? id = await secureStorage.read(key: 'id') ?? '';
  return id;
}

Future<String> getSchoolId() async {
  // Replace 'userName' with the key you used to store the name in secure storage
  String? id = await secureStorage.read(key: 'school_id') ?? '';
  return id;
}

Future<String> getToken() async {
  // Replace 'userName' with the key you used to store the name in secure storage
  String? token = await secureStorage.read(key: 'token') ?? "";
  return token;
}

Future<String> getRole() async {
  // Replace 'userName' with the key you used to store the name in secure storage
  String? role = await secureStorage.read(key: 'role') ?? '';
  return role;
}
