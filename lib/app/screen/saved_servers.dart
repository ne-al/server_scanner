import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:server_scanner/app/screen/search_server_view.dart';

class SavedServersPage extends StatefulWidget {
  const SavedServersPage({super.key});

  @override
  State<SavedServersPage> createState() => _SavedServersPageState();
}

class _SavedServersPageState extends State<SavedServersPage> {
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: ValueListenableBuilder(
        valueListenable: Hive.box('servers').listenable(),
        builder: (context, value, child) {
          List serverData = value.toMap().values.toList();

          return SearchServerView(
            serverData: serverData,
            initialLimit: 10,
            query: {},
            isSavedServerView: true,
          );
        },
      ),
    );
  }
}
