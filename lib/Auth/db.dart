import 'dart:io';
import '../Methods/getTokenData.dart';
import 'package:dio/dio.dart';

Dio dio = new Dio(BaseOptions(
  headers: {
    HttpHeaders.userAgentHeader: 'dio',
    'Content-Type': 'application/json',
  },
));
  
  
  // String token = 'YOUR_TOKEN_HERE';

  // // Set headers with the token
  // dio.options.headers['Content-Type'] = 'application/json';
  // dio.options.headers['Authorization'] = 'Bearer $token';
