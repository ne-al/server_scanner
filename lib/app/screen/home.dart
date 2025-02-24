import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_scanner/app/screen/saved_servers.dart';
import 'package:server_scanner/app/screen/search/server_ip_search.dart';
import 'package:server_scanner/app/screen/search_server.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  PaneDisplayMode displayMode = PaneDisplayMode.compact;
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: selectedIndex,
        displayMode: displayMode,
        onItemPressed: (index) {
          if (index == selectedIndex) {
            if (displayMode == PaneDisplayMode.open) {
              setState(() => displayMode = PaneDisplayMode.compact);
            } else if (displayMode == PaneDisplayMode.compact) {
              setState(() => displayMode = PaneDisplayMode.open);
            }
          }
        },
        onChanged: (index) => setState(() => selectedIndex = index),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.search),
            title: Text('Scan Server', style: GoogleFonts.inter()),
            body: SearchServerPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.server),
            title: Text('Lookup Server', style: GoogleFonts.inter()),
            body: ServerIpSearchPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.save),
            title: Text('Saved Server', style: GoogleFonts.inter()),
            body: SavedServersPage(),
          ),
        ],
      ),
    );
  }
}
