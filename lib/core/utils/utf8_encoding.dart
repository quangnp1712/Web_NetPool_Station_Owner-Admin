import 'dart:convert';

class Utf8Encoding {
  String decode(String input) {
    try {
      String result = utf8.decode(input.toString().runes.toList());
      return result;
    } on FormatException {
      return input;
    } catch (e) {
      return input;
    }
  }
}
