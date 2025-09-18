import 'dart:convert';

class Utf8Encoding {
  String decode(String input) {
    return utf8.decode(input.toString().runes.toList());
  }
}
