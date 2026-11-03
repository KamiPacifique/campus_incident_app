import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';
import 'auth_scaffold.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? '';

    return AuthScaffold(
      title: 'Verify your email',
      icon: Icons.mark_email_unread_rounded,
      subtitle: 'We sent a verification link to $email. '
          'Open it, then come back and continue.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (auth.error != null) ...[
            ErrorBanner(message: auth.error!),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Only ALU email addresses can use this app. Check your spam folder if you do not see the message.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'I have verified my email',
            icon: Icons.verified_rounded,
            isLoading: auth.isLoading,
            onPressed: () async {
              final verified = await auth.checkVerified();
              if (!context.mounted) return;
              if (!verified && auth.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Not verified yet. Open the link in your email first.'),
                ));
              }
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.send_rounded, size: 18),
            onPressed: auth.isLoading
                ? null
                : () async {
                    final ok = await auth.resendVerification();
                    if (!context.mounted || !ok) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Verification email sent.')));
                  },
            label: const Text('Resend email'),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: auth.isLoading ? null : auth.signOut,
              child: const Text('Use a different account'),
            ),
          ),
        ],
      ),
    );
  }
}
