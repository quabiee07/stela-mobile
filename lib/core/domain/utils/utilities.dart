// import 'package:flutter/material.dart';
// import 'package:location2/location2.dart';
import 'package:logger/logger.dart';

logg(data) {
  Logger().i(data, time: DateTime.now());
}

// MediaType getContentType(String filePath) {
//   final ext = filePath.split('.').last.toLowerCase();

//   const mimeTypes = {
//     // Images
//     'jpg': 'image/jpeg',
//     'jpeg': 'image/jpeg',
//     'png': 'image/png',
//     'webp': 'image/webp',
//     'gif': 'image/gif',
//     'bmp': 'image/bmp',
//     'svg': 'image/svg+xml',

//     // Audio
//     'mp3': 'audio/mpeg',
//     'wav': 'audio/wav',
//     'ogg': 'audio/ogg',
//     'aac': 'audio/aac',
//     'm4a': 'audio/mp4',
//     'flac': 'audio/flac',
//     'opus': 'audio/opus',

//     // Video
//     'mp4': 'video/mp4',
//     'mov': 'video/quicktime',
//     'avi': 'video/x-msvideo',
//     'wmv': 'video/x-ms-wmv',
//     'webm': 'video/webm',
//     'mkv': 'video/x-matroska',

//     // Documents
//     'pdf': 'application/pdf',
//     'doc': 'application/msword',
//     'docx':
//         'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
//     'xls': 'application/vnd.ms-excel',
//     'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
//     'ppt': 'application/vnd.ms-powerpoint',
//     'pptx':
//         'application/vnd.openxmlformats-officedocument.presentationml.presentation',
//     'txt': 'text/plain',
//     'csv': 'text/csv',
//     'json': 'application/json',
//     'xml': 'application/xml',
//     'html': 'text/html',
//     'htm': 'text/html',
//     'zip': 'application/zip',
//     'rar': 'application/vnd.rar',
//     '7z': 'application/x-7z-compressed',
//     'tar': 'application/x-tar',
//   };

//   final mime = mimeTypes[ext] ?? 'application/octet-stream';
//   final parts = mime.split('/');
//   return MediaType(parts[0], parts[1]);
// }

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

// Future<bool> enableLocation({
//   required BuildContext context,
//   required dynamic location,

// }) async {
//   bool _serviceEnabled;
//   PermissionStatus _permissionGranted;

//   _serviceEnabled = await location.serviceEnabled();
//   if (!_serviceEnabled) {
//     _serviceEnabled = await location.requestService();
//     if (!_serviceEnabled) {
//       return false; // Service not enabled
//     }
//   }

//   _permissionGranted = await location.hasPermission();
//   if (_permissionGranted == PermissionStatus.denied) {
//     _permissionGranted = await location.requestPermission();
//     if (_permissionGranted != PermissionStatus.granted) {
//       return false; // Permission denied
//     }
//   }
//   return true; // Service & permission granted
// }

String formatPrice(double price) {
    // Format number with comma separator
    String priceStr = price.toStringAsFixed(0);
    String result = '';
    int count = 0;
    
    for (int i = priceStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = priceStr[i] + result;
      count++;
    }
    
    return result;
  }
