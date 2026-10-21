import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

Future<bool> confirmDialog(
  BuildContext context,
  String message, {
  String? confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message, style: const TextStyle(fontSize: 18)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(ctx.tr('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel ?? ctx.tr('yes')),
        ),
      ],
    ),
  );
  return result ?? false;
}
