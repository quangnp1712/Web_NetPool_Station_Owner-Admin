import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String domainUrl = "${dotenv.env["DOMAIN"]}";

  //! Verification Code API !//
  final String AccountSendVerificationUrl =
      "$domainUrl/v1/public/verification-code/account-verification/send";
}
