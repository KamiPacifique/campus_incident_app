import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/form_label.dart';
import '../../widgets/primary_button.dart';
import 'auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final ok = await context
        .read<AuthProvider>()
        .register(_name.text, _email.text, _password.text);
    // The AuthGate now shows the verify-email screen; remove this route.
    if (ok && mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      showBack: true,
      title: 'Create your account',
      subtitle:
          'Use your ALU email. We will send a link to verify it before you can continue.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auth.error != null) ...[
              ErrorBanner(message: auth.error!),
              const SizedBox(height: 16),
            ],
            const FormLabel('Full name'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: Validators.name,
              decoration: const InputDecoration(hintText: 'Amina Hassan'),
            ),
            const SizedBox(height: 16),
            const FormLabel('ALU email'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.aluEmail,
              decoration:
                  const InputDecoration(hintText: 'name@alustudent.com'),
            ),
            const SizedBox(height: 16),
            const FormLabel('Password', hint: '(8+ characters, letters and numbers)'),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              validator: Validators.password,
              decoration: InputDecoration(
                hintText: 'Create a password',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const FormLabel('Confirm password'),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => Validators.confirmPassword(v, _password.text),
              decoration:
                  const InputDecoration(hintText: 'Re-enter your password'),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create account',
              onPressed: _submit,
              isLoading: auth.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
