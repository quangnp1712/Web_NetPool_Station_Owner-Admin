import 'dart:convert';

import 'package:http/http.dart' as http;

class AppException implements Exception {
  final String? message;
  final String? prefix;
  final int? status;

  AppException([this.message, this.prefix, this.status]);
}

class BadRequestException extends AppException {
  BadRequestException([String? message, int? status])
      : super(message, 'Bad request', status);
}

class FetchDataException extends AppException {
  FetchDataException([String? message, int? status])
      : super(message, 'Unable to process the request', status);
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException([String? message, int? status])
      : super(message, 'Api not responding', status);
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException([String? message, int? status])
      : super(message, 'Unauthorized request', status);
}

class NotFoundException extends AppException {
  NotFoundException([String? message, int? status])
      : super(message, 'Page not found', status);
}

class TypeErrorException extends AppException {
  TypeErrorException([String? message, int? status])
      : super(message, 'Type Error', status);
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException([String? message, int? status])
      : super(message, 'Internal Server Error', status);
}

class ConflictErrorException extends AppException {
  ConflictErrorException([String? message, int? status])
      : super(message, 'Internal Server Error', status);
}

dynamic processResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson =
          (response.body.isNotEmpty) ? jsonDecode(response.body) : "";
      return {"body": responseJson, "success": true};
    case 201:
      var responseJson = jsonDecode(response.body);
      return {"body": responseJson, "success": true};
    case 400: //Bad request
      throw BadRequestException(
          jsonDecode(response.body)['data'], response.statusCode);
    case 401: //Unauthorized
      throw UnAuthorizedException(
          jsonDecode(response.body)['data'], response.statusCode);
    case 403: //Forbidden
      throw UnAuthorizedException(
          jsonDecode(response.body)['data'], response.statusCode);
    case 404: //Resource Not Found
      throw NotFoundException(
          jsonDecode(response.body)['data'], response.statusCode);
    case 500: //Internal Server Error
      throw InternalServerErrorException(
          jsonDecode(response.body)['data'], response.statusCode);
    case 409: //Internal Server Error
      throw ConflictErrorException(
          jsonDecode(response.body)['data'], response.statusCode);
    default:
      throw FetchDataException('Something went wrong! ${response.statusCode}');
  }
}
