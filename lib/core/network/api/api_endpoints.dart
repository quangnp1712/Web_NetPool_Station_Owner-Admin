import 'package:flutter_dotenv/flutter_dotenv.dart';

// String domainUrl = String.fromEnvironment('DOMAIN',
// defaultValue:
//     'https://nps-core-service-6b8b355ec2a3.herokuapp.com' // Link dự phòng chạy local
// );
String domainUrl = "${dotenv.env["DOMAIN"]}";

class ApiEndpoints {}
