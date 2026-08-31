import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scaffold helper for Cubit-driven screens (replaces ProviderWidget for new work).
class CubitScaffold<C extends Cubit<S>, S> extends StatelessWidget {
  const CubitScaffold({
    required this.create,
    required this.children,
    this.padding = 20,
    this.resizeInsets,
    this.canPop = true,
    this.onPop,
    this.bottomSheet,
    this.floatingActionButton,
    this.backgroundColor,
    this.buildWhen,
    super.key,
  });

  final C Function(BuildContext context) create;
  final List<Widget> Function(BuildContext context, C cubit, S state, ThemeData theme)
      children;
  final double padding;
  final bool? resizeInsets;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool canPop;
  final void Function(bool, Object?)? onPop;
  final bool Function(S previous, S current)? buildWhen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: create,
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: onPop,
        child: BlocBuilder<C, S>(
          buildWhen: buildWhen,
          builder: (context, state) {
            final cubit = context.read<C>();
            return Scaffold(
              resizeToAvoidBottomInset: resizeInsets,
              backgroundColor: backgroundColor,
              body: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children(context, cubit, state, Theme.of(context)),
                  ),
                ),
              ),
              bottomNavigationBar: bottomSheet,
              floatingActionButton: floatingActionButton,
            );
          },
        ),
      ),
    );
  }
}
