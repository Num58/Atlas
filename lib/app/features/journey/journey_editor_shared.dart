import 'package:flutter/material.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';

class JourneyEditorScaffold extends StatelessWidget {
  const JourneyEditorScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [child],
        ),
      ),
    );
  }
}

void showJourneyEditorError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
