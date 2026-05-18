import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stela_mobile/features/auth/data/dto/user_model_dto.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';

void logg(dynamic data) {
  Logger().i(data, time: DateTime.now());
}

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

String greetingMessage() {
  var timeNow = DateTime.now().hour;

  if (timeNow <= 12) {
    return 'Good Morning';
  } else if ((timeNow > 12) && (timeNow <= 16)) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}

Future<UserModel?> getCachedUser() async {
  try {
    final prefs = await getIt.getAsync<SharedPreferences>();
    final userString = prefs.getString(userKey);

    if (userString != null) {
      try {
        final userMap = jsonDecode(userString);
        cachedUser = UserModelDto.fromJson(userMap).toEntity();
      } catch (e) {
        // ❗ Corrupted cache — clear it
        await prefs.remove(userKey);
        logg('Corrupted user cache cleared');
      }
    }
  } catch (e) {
    logg(e.toString());
  }
  return cachedUser;
}

String formatCurrency(dynamic number, {bool decimal = true}) {
  // Clean the input by removing currency symbol and commas
  String cleanNumber = number
      .toString()
      .replaceAll(naira, '') // Remove currency symbol if present
      .replaceAll(',', '') // Remove any commas
      .trim(); // Remove any whitespace

  try {
    final oCcy = decimal
        ? NumberFormat("#,##0.00", "en_US")
        : NumberFormat("#,##0", "en_US");

    return '$naira${oCcy.format(double.parse(cleanNumber))}';
  } catch (e) {
    print('Error formatting currency: $e');
    return '${naira}0'; // Return default value if parsing fails
  }
}

String getInitials(String firstName, String lastName) {
  String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
  String lastInitial = lastName.isNotEmpty ? lastName[0] : '';
  return (firstInitial + lastInitial).toUpperCase();
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

String extractFilename(String url) {
  List<String> parts = url.split('/');
  return parts.last;
}

String formatDate(DateTime date) {
  return DateFormat("d MMM").format(date); // e.g., 6 Mar
}

String formatDay(DateTime date) {
  return DateFormat('EEE, d MMMM').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('h:mm a').format(date);
}

String formatBirthday(DateTime date) {
  return DateFormat("d MMMM yyyy").format(date); // e.g., 6 March 2005
}

String formatId(String objectId) {
  final firstPart = objectId.substring(0, 8);
  final number =
      int.parse(firstPart, radix: 16) % 10000000; // limit to 7 digits
  return '#${number.toString().padLeft(7, '0')}';
}

String formatFullDate(DateTime dateTime) {
  final formatter = DateFormat("EEEE, MMMM dd yyyy ");
  return formatter.format(dateTime);
}

Map<String, TimeOfDay> extractTimeRange(String input) {
  final regex = RegExp(r'(\d+)\s*-\s*(\d+)\s*(AM|PM)', caseSensitive: false);
  final match = regex.firstMatch(input);

  if (match != null) {
    final startHour = int.parse(match.group(1)!);
    final endHour = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    final startTime = TimeOfDay(
      hour: period == 'PM' && startHour != 12 ? startHour + 12 : startHour % 12,
      minute: 0,
    );
    final endTime = TimeOfDay(
      hour: period == 'PM' && endHour != 12 ? endHour + 12 : endHour % 12,
      minute: 0,
    );

    return {'start': startTime, 'end': endTime};
  }

  throw Exception('Could not parse time range.');
}

String getLoginMessage(bool isSeller) {
  if (isSeller) {
    return "🎉 You’re logged in! Let’s connect you with more clients.";
  } else {
    return "🎉 You’re in! Let’s find the perfect service for you.";
  }
}
