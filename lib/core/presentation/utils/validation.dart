extension Validation on String {
  String? validateNullableFullName() {
    if (trim().isEmpty) {
      return null;
    }
    return validateFullName();
  }

  String? validateName() {
    if (trim().isEmpty) {
      return '*required';
    }
    return null;
  }

  String? validateFullName() {
    if (trim().isEmpty) {
      return '*required';
    }
    if (length == 1) {
      return 'initials are not allowed';
    }

    final split = trim().split(" ");
    if (split.length < 2) {
      return 'Full Name required';
    }

    return null;
  }

  String? validateField() {
    if (trim().isEmpty) {
      return '*required';
    }
    return null;
  }

  String? validateAccountNumber() {
    if (trim().isEmpty) {
      return '*required';
    }
    if (isAccountNumber()) {
      return null;
    }
    return 'invalid account number';
  }

  String? validatePhone() {
    if (trim().isEmpty) {
      return '*required';
    }

    // Remove all spaces, dashes, dots, and parentheses for validation
    final cleanedNumber = replaceAll(RegExp(r'[\s\-\.\(\)]'), '');

    // International phone number regex
    // Accepts:
    // - Optional + at the beginning
    // - Country code (1-4 digits)
    // - Main number (6-14 digits)
    // Total length: 7-15 digits (ITU-T E.164 standard)
    final regex = RegExp(r'^\+?[1-9]\d{6,14}$');

    if (regex.hasMatch(cleanedNumber)) {
      return null;
    }
    return 'Invalid phone number';
  }

  // String? validatePhone() {
  //   if (trim().isEmpty) {
  //     return '*required';
  //   }
  //   final regex = RegExp(r'^(?:\+234.{10}|234.{10}|0.{10})$');
  //   if (regex.hasMatch(this)) {
  //     return null;
  //   }
  //   return 'invalid phone number';
  // }

  String? validateEmail() {
    if (trim().isEmpty) {
      return '*required';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (regex.hasMatch(this)) {
      return null;
    }

    return 'invalid email address';
  }

  String? validatePassword() {
    if (isEmpty) {
      '*required';
    }
    RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*_ ]+).{8,}$');
    if (regex.hasMatch(this)) {
      return null;
    }

    if (!isContainUppercase()) {
      return 'must have uppercase letters';
    }

    if (!isContainLowercase()) {
      return 'must have lowercase letters';
    }

    if (!isSpecial()) {
      return 'must contain any of !@#\$%^&*_';
    }

    if (length < 8) {
      'must be at least 8 characters';
    }

    return 'invalid password';
  }

  String? validateRePassword(String password) {
    if (this != password) {
      return 'password mismatch';
    }
    return null;
  }

  String? validateIdentity() {
    if (isEmpty) {
      return '*required';
    }

    if (isPhone()) {
      return validatePhone();
    }

    if (isEmail()) {
      return validateEmail();
    }

    return 'invalid email or phone';
  }

  String? validateLoginPassword() {
    if (isEmpty) {
      return '*required';
    }
    return null;
  }

  String removeDecimalPart() {
    if (contains('.')) {
      return split('.')[0];
    }
    return this;
  }

  bool isContainUppercase() {
    return RegExp(r'^(?=.*[A-Z]).+$').hasMatch(this);
  }

  bool isContainLowercase() {
    return RegExp(r'^(?=.*[a-z]).+$').hasMatch(this);
  }

  bool isSpecial() {
    return RegExp(r'^(?=.*[!@#$%^&*_ ]).+$').hasMatch(this);
  }

  bool isNumber() {
    return RegExp(r'^(?=.*[0-9]).+$').hasMatch(this);
  }

  bool isPhone() {
    final regex = RegExp(r'^(0|\+?234)(.*)$');
    return regex.hasMatch(this);
  }

  bool isEmail() {
    final regex = RegExp(r'^([a-zA-Z0-9])(.*)$');
    return regex.hasMatch(this);
  }

  bool isAccountNumber() {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(this);
  }

  String? validateUrl() {
    if (trim().isEmpty) {
      return '*required';
    }
    final regex = RegExp(r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/.*)?$');
    if (regex.hasMatch(this)) {
      return null;
    }
    return 'invalid url';
  }
}

extension Validate on List<bool> {
  bool validate() {
    return !any((element) {
      return !element;
    });
  }
}

extension ValidateDropdown on dynamic {
  String? validate() {
    if (this == null) {
      return '*required';
    }
    return null;
  }
}
