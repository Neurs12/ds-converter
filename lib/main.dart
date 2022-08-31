import 'package:flutter/material.dart';
import 'mainui.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.green,
          useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const NavigateScreen()));
}

class NavigateScreen extends StatelessWidget {
  const NavigateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const UI()));
    });
    return const Scaffold();
  }
}
