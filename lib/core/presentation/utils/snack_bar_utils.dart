import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:logger/logger.dart';
import 'package:toastification/toastification.dart';

extension SnackbarStateless on BuildContext {
  void showSuccess(String message) {
    customToast(message, 1);
  }

  void showError(String message) {
    customToast(
      message,
      3,
    );
  }

  void showWarning(String message) {
    customToast(
      message,
      2,
    );
  }

  void logg(String log) {
    return Logger().i(log);
  }
}

extension Snackbar on State {
  void showSuccess(String message) {
    context.showSuccess(message);
  }

  void logg(String log) {
    context.logg(log);
  }

  void showError(String message) {
    context.showError(message);
  }

  void showWarning(String message) {
    context.showWarning(message);
  }
}


customToast(String message, [type = 1]) {
  final AppIconData icon;
  final String title;
  // final Color bgColor;
  // final Color borderColor;
  final Color iconColor;
  final ToastificationType toastType;
  switch (type) {
    case 1:
      icon = AppIcons.checkCircle;
      title = "Success";
      toastType = ToastificationType.success;
      // bgColor = success50;
      // borderColor = success200;
      iconColor = success500;
      break;
    case 2:
      icon = AppIcons.alert;
      title = "Warning";
      toastType = ToastificationType.warning;
      // bgColor = warning50;
      // borderColor = warning100;
      iconColor = warning500;
      break;
    default:
      icon = AppIcons.error;
      title = "Error";
      toastType = ToastificationType.error;
      // bgColor = error50;
      // borderColor = error400;
      iconColor = error500;
  }

  return toastification.show(
    type: toastType,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(title, style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w600)),
    description: Text(message, style: TextStyle(color: neutral600)),
    alignment: Alignment.topRight,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    icon: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        // color: bgColor,
        // border: Border.all(color: borderColor),
        // borderRadius: BorderRadius.circular(8),
      ),
      child: AppIcon(icon, color: white, size: 24),
    ),
    showIcon: true, // show or hide the icon
    primaryColor: iconColor,
    backgroundColor: neutral50,
    foregroundColor: neutral700,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(4),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      ),
    ],
    // showProgressBar: true,
    closeButton: ToastCloseButton(
      showType: CloseButtonShowType.always,
      buttonBuilder: (context, onClose) {
        return IconButton(
          onPressed: onClose,
          icon: const AppIcon(AppIcons.close, color: neutral700, size: 18),
        );
      },
    ),

    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: true,
    applyBlurEffect: false,
    // callbacks: ToastificationCallbacks(
    //   onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
    //   onCloseButtonTap:
    //       (toastItem) => print('Toast ${toastItem.id} close button tapped'),
    //   onAutoCompleteCompleted:
    //       (toastItem) => print('Toast ${toastItem.id} auto complete completed'),
    //   onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
    // ),
  );
}

// Flushbar customFlushBar(String message, [type = 1]) {
//   final IconData icon;
//   final Color color;
//   final Color iconColor;
//   switch (type) {
//     case 1:
//       icon = Icons.check_circle;
//       color = primaryColor;
//       iconColor = Colors.white;
//       break;
//     case 2:
//       icon = Icons.warning;
//       color = primaColor;
//       iconColor = Colors.black;
//       break;
//     default:
//       icon = Icons.error;
//       color = primColor;
//       iconColor =  Colors.white;
//   }

//   return Flushbar(
//     messageText: Text(
//       message,
//       style: TextStyle(
//           fontFamily: 'SFProRounded',
//           fontWeight: FontWeight.w500,
//           fontSize: 16,
//           color: iconColor),
//     ),
//     messageColor: iconColor,
//     icon: Icon(
//       icon,
//       color: iconColor,
//     ),
//     flushbarPosition: FlushbarPosition.TOP,
//     reverseAnimationCurve: Curves.fastLinearToSlowEaseIn,
//     forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
//     shouldIconPulse: true,
//     backgroundColor: color,
//     isDismissible: true,
//     duration: const Duration(seconds: 3),
//     dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//     flushbarStyle: FlushbarStyle.FLOATING,
//     boxShadows: const [],
//     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//     borderRadius: BorderRadius.circular(16),
//   );
// }
