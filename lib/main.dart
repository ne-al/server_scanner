import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:server_scanner/app/screen/home.dart';
import 'package:system_theme/system_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('servers');
  await Hive.openBox('settings');

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
      ),
      home: const HomePage(),
    );
  }
}
