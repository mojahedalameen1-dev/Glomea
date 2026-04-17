import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.bgPage,
      appBar: title != null 
        ? AppBar(
            title: Text(title!),
            actions: actions,
            leading: showBackButton ? const BackButton() : null,
          )
        : null,
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
