import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // final token = RootIsolateToken.instance!;
  // final receivePort = ReceivePort();
  // await Isolate.spawn(isolateEntry, [receivePort.sendPort, token]);
  // print(await receivePort.first);
}

// class IsolateBinding extends BindingBase with ServicesBinding {}

// void isolateEntry(List<dynamic> args) async {
//   final sendPort = args[0] as SendPort;
//   final token = args[1] as RootIsolateToken;
//   BackgroundIsolateBinaryMessenger.ensureInitialized(token);
//   try {
//     IsolateBinding();
//     if (ServicesBinding.instance != null) {
//        sendPort.send("Success");
//     } else {
//        sendPort.send("Instance is null");
//     }
//   } catch (e) {
//     sendPort.send("Error: $e");
//   }
// }
