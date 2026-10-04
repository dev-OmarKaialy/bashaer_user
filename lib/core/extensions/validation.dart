import 'package:phone_parser/phone_parser.dart';

extension Validator on String {
  bool isValidEmail() {
    return RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
      caseSensitive: false,
    ).hasMatch(this);
  }

  bool isValidNum() {
    return RegExp(r"^[0-9]", caseSensitive: false).hasMatch(this);
  }

  bool isNotShortText() {
    return (isNotEmpty && length > 1);
  }

  bool isValidPhone({String destinationCountry = 'SY'}) {
    final value = trim();
    if (value.isEmpty) return false;

    try {
      final phoneNumber = PhoneNumber.parse(value, destinationCountry: destinationCountry);
      return phoneNumber.isValid();
    } catch (_) {
      return false;
    }
  }

  bool isValidPassword() {
    return RegExp(r'[a-z0-9]{1,}', caseSensitive: false, multiLine: false).hasMatch(this);
  }

  bool isValidWebsite() {
    return RegExp(
      r"^(((https:\/\/)|(http:\/\/)){1})?(w{3}\.)?([a-z0-9])(.[a-z0-9]{1,})",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }

  bool isValidFacebook() {
    return RegExp(
      r"^((https:\/\/){1})?(w{3}\.)?(facebook)(.com)\/[0-9a-zA-Z]+\/?",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }

  bool isValidInstagram() {
    return RegExp(
      r"^((https:\/\/){1})?(w{3}\.)?(instagram)(.com)\/[0-9a-zA-Z]+\/?",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }

  bool isValidLinkedin() {
    return RegExp(
      r"^((https:\/\/){1})?(w{3}\.)?(linkedin)(.com)\/[0-9a-zA-Z]+\/?",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }

  bool isValidTiktok() {
    return RegExp(
      r"^((https:\/\/){1})?(w{3}\.)?(tiktok)(.com)\/[0-9a-zA-Z]+\/?",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }

  bool isValidYoutube() {
    return RegExp(
      r"^((https:\/\/){1})?(w{3}\.)?(youtube)(.com)\/[0-9a-zA-Z]+\/?",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }
}
