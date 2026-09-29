import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/script_repository.dart';
import 'logic/scripts_provider.dart';
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi portrait untuk kemudahan rekaman kamera depan secara default
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final repository = ScriptRepository();
  final scriptsProvider = ScriptsProvider(repository: repository);

  runApp(TeleprompterApp(scriptsProvider: scriptsProvider));
}

class TeleprompterApp extends StatelessWidget {
  final ScriptsProvider scriptsProvider;

  const TeleprompterApp({
    super.key,
    required this.scriptsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teleprompter Free',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(provider: scriptsProvider),
    );
  }
}
