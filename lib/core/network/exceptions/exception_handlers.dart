import 'dart:async';
import 'dart:io';

import 'package:web_netpool_station_owner_admin/core/network/exceptions/app_exceptions.dart';

class ExceptionHandlers {
  getExceptionString(error) {
    if (error is SocketException) {
      return {
        "success": false,
        "message": 'No internet connection.',
      };
    } else if (error is HttpException) {
      return {
        "success": false,
        "message": 'HTTP error occured.',
      };
    } else if (error is FormatException) {
      return {
        "success": false,
        "message": 'Invalid data format',
      };
    } else if (error is TimeoutException) {
      return {
        "success": false,
        "message": 'Request timedout.',
      };
    } else if (error is BadRequestException) {
      return {
        "success": false,
        "status": error.status,
        "message": error.message.toString()
      };
    } else if (error is UnAuthorizedException) {
      return {
        "success": false,
        "status": error.status,
        "message": error.message.toString()
      };
    } else if (error is NotFoundException) {
      return {
        "success": false,
        "status": error.status,
        "message": error.message.toString()
      };
    } else if (error is FetchDataException) {
      return {
        "success": false,
        "status": error.status,
        "message": error.message.toString()
      };
    } else if (error is TypeErrorException) {
      return {
        "success": false,
        "status": error.status,
        "message": error.runtimeType.toString()
      };
    } else {
      return {
        "success": false,
        "status": error.status,
        "message": error.message.toString()
      };
    }
  }
}
