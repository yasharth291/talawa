import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class Validator {
  static String validateURL(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Please verify URL first'.toUpperCase();
    }
    return null;
  }

  static String validateFirstName(String value) {
    // ignore: unnecessary_raw_strings
    const String pattern = r'(?=.*?[A-Za-z]).+';
    final RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'Firstname must not be left blank.';
    }
    if (!regex.hasMatch(value)) {
      return "Invalid Firstname";
    }
    return null;
  }

  static String validateLastName(String value) {
    // ignore: unnecessary_raw_strings
    const String pattern = r'(?=.*?[A-Za-z]).+';
    final RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'Lastname must not be left blank.';
    }
    if (!regex.hasMatch(value)) {
      return "Invalid Lastname";
    }
    return null;
  }

  static String validateEmail(
    String email,
  ) {
    // If email is empty return.
    if (email.isEmpty) {
      return "Email must not be left blank";
    }

    final bool isValid = EmailValidator.validate(
      email,
    );
    if (!isValid) {
      return 'Please enter a valid Email Address';
    }
    return null;
  }

  static String validatePassword(
    String password,
  ) {
    // If password is empty return.
    if (password.isEmpty) {
      return "Password must not be left blank";
    }
    const String pattern =
        r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*%^~.]).{8,}$';
    final RegExp regExp = RegExp(pattern);

    //Regex for no spaces allowed
    const String noSpaces = r'^\S+$';
    final RegExp noSpaceRegex = RegExp(noSpaces);

    if (!regExp.hasMatch(password)) {
      return "Invalid Password";
    }
    if (!noSpaceRegex.hasMatch(password)) {
      return "Password must not contain spaces";
    }

    return null;
  }

  static String validatePasswordConfirm(
    String value,
    String comparator,
  ) {
    if (value != comparator) {
      return 'Password does not match original';
    }
    return null;
  }

  static String validateTitle(
    String value,
  ) {
    if (value.length < 4) {
      return 'Title must be at least 4 characters.';
    }

    return null;
  }

  static String validateDateTime(
    DateTime value,
  ) {
    if (value == null) {
      return 'Date field must not be left blank.';
    }

    return null;
  }

  static String validateDescription(
    String value,
  ) {
    if (value.length < 5 || value.length > 50) {
      return 'Description field must range between\n 5 and 30 characters';
    }

    return null;
  }

  static String validateOrgName(
    String value,
  ) {
    final String validatingValue = value.replaceAll(RegExp(r"\s+"), "");
    debugPrint(validatingValue.length.toString());
    if (validatingValue.isEmpty) {
      return 'Organization Description must not be left blank.';
    }
    if (value.length > 40) {
      return 'Organization Name must not exceed 40 letters';
    }
    return null;
  }

  static String validateOrgDesc(
    String value,
  ) {
    final String validatingValue = value.replaceAll(RegExp(r"\s+"), "");
    debugPrint(validatingValue.length.toString());
    if (validatingValue.isEmpty) {
      return 'Organization Description must not be left blank.';
    }
    if (value.length > 5000) {
      return 'Organization Description must not exceed 5000 letters';
    }
    return null;
  }

  static String validateOrgAttendeesDesc(
    String value,
  ) {
    final String validatingValue = value.replaceAll(RegExp(r"\s+"), "");
    debugPrint(validatingValue.length.toString());
    if (validatingValue.isEmpty) {
      return 'Attendees Description must not be left blank.';
    }
    if (value.length > 5000) {
      return 'Attendees Description must not exceed 5000 letters';
    }
    return null;
  }
}
