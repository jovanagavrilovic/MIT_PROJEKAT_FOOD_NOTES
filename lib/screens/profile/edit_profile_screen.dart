import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";
    final fallbackName = email.contains("@") ? email.split("@").first : "User";
    _nameCtrl.text = (user?.displayName?.trim().isNotEmpty == true)
        ? user!.displayName!.trim()
        : fallbackName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name can't be empty")));
      return;
    }

    setState(() => _saving = true);
    try {
      await user.updateDisplayName(newName);
      await user.reload();

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No email found for this account.")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Reset link sent to $email")));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to send reset email")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit profile")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Display name",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: scheme.surfaceVariant.withOpacity(0.75),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(text: user?.email ?? ""),
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: scheme.surfaceVariant.withOpacity(0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Save"),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: _saving ? null : _resetPassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Reset password ( via email)"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
