import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/form_label.dart';
import '../../widgets/primary_button.dart';
import 'auth_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    // On success the AuthGate swaps this screen out automatically.
    await context.read<AuthProvider>().signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in with your ALU email to report and track campus issues.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auth.error != null) ...[
              ErrorBanner(message: auth.error!),
              const SizedBox(height: 16),
            ],
            const FormLabel('ALU email'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              validator: Validators.aluEmail,
              onChanged: (_) => auth.clearError(),
              decoration:
                  const InputDecoration(hintText: 'name@alustudent.com'),
            ),
            const SizedBox(height: 16),
            const FormLabel('Password'),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password is required' : null,
              onChanged: (_) => auth.clearError(),
              decoration: InputDecoration(
                hintText: 'Your password',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
                label: 'Sign in', onPressed: _submit, isLoading: auth.isLoading),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        auth.clearError();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const RegisterScreen()));
                      },
                child: const Text('New here? Create an account'),
              ),
            ),
            if (kDebugMode) const _DemoAccounts(),
          ],
        ),
      ),
    );
  }
}

/// Visible in debug builds only, handy for the demo video.
class _DemoAccounts extends StatelessWidget {
  const _DemoAccounts();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Demo accounts (debug only)\n'
        'Student: student@alustudent.com / Student123\n'
        'Staff: staff@alueducation.com / Staff1234',
        style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.5),
      ),
    );
  }
}
