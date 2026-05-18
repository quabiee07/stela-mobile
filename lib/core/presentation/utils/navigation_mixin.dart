import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushReplacement(Widget screen) {
    return Navigator.of(this).pushReplacement(MaterialPageRoute(builder: (_) {
      return screen;
    }));
  }

  Future<dynamic> pushNamedReplacement(String route, {Object? args}) {
    return Navigator.of(this).pushReplacementNamed(route, arguments: args);
  }

  Future<dynamic> push(Widget screen) {
    return Navigator.of(this).push(MaterialPageRoute(builder: (_) {
      return screen;
    }));
  }

  Future<dynamic> animPush(Widget screen) {
    return Navigator.of(this).push(_createRoute(screen: screen));
  }

  Future<dynamic> pushNamed(String route, {Object? args}) {
    return Navigator.of(this).pushNamed(route, arguments: args);
  }

  pop([Object? arg]) {
    Navigator.of(this).pop(arg);
  }

  Future<dynamic> pushAndReplaceUntil(Widget screen, String id) {
    return Navigator.of(this).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) {
      return screen;
    }), (route) {
      return route.settings.name != id;
    });
  }

  Future<dynamic> pushNamedAndClear(String id, {Object? args}) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
        id, (Route<dynamic> route) => false,
        arguments: args);
  }

  Future<dynamic> pushNamedAndReplaceUntil(String route, String id,
      {Object? args}) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
        route, ModalRoute.withName(id),
        arguments: args);
  }

  popUntil(List<String> id) {
    Navigator.of(this).popUntil((route) {
      return id.contains(route.settings.name);
    });
  }

  T getArgs<T>() {
    return ModalRoute.of(this)?.settings.arguments as T;
  }

  Route _createRoute({required Widget screen}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final curve = Sprung.overDamped;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
