import 'dart:async';

import 'package:flutter/material.dart';

class CustomProvider extends ChangeNotifier {
  StreamController? _stream;
  bool loading = false;
  void listen(Function(dynamic) event){
    _stream = StreamController();
    _stream?.stream.listen(event);
  }

  onLoad(){
    loading = !loading;
    notifyListeners();
  }

  void close(){
    _stream?.close();
  }

  void add(data){
    if(data is String){
      if(data.contains('ThrottlerException')){
        return;
      }
    }
    _stream?.add(data);
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}