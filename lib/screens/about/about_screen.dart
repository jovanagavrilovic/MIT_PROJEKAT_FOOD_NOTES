import 'package:flutter/material.dart';



class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    const bodyTextStyle = TextStyle(fontSize: 15, height: 1.5);

    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Card(
              color: scheme.surface,
              surfaceTintColor: Colors.transparent,

              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 64),
                    const SizedBox(height: 14),

                    
                    const Text(
                      "Food Notes",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      "Food Notes is a simple and intuitive app designed to help you save recipes, "
                      "organize your meals, and keep personal food notes all in one place.",
                      textAlign: TextAlign.center,
                      style: bodyTextStyle,
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "With an easy-to-use interface, you can quickly add new recipes, edit existing ones, "
                      "and keep track of your favorite dishes. Whether you're cooking every day or just collecting ideas, "
                      "Food Notes helps you stay organized and inspired.",
                      textAlign: TextAlign.center,
                      style: bodyTextStyle,
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Join our growing community, share your favorite recipes, and discover meals from people all around the world.",
                      textAlign: TextAlign.center,
                      style: bodyTextStyle,
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cook with us!"),
                      ),
                    ),



                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    const Text(
                      "Made with Flutter\nVersion 1.0.0",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
