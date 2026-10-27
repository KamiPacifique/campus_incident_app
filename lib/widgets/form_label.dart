import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key, this.hint});
  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(TextSpan(
        text: text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
        children: [
          if (hint != null)
            TextSpan(
              text: ' $hint',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted),
            ),
        ],
      )),
    );
  }
}
