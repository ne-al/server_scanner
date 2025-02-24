import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_scanner/app/screen/search/server_ip_search.dart';
import 'package:server_scanner/app/screen/search_server.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text('Home', style: GoogleFonts.inter()),
        automaticallyImplyLeading: false,
      ),
      content: SafeArea(
        child: Center(
          child: Column(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => const SearchServerPage(),
                      ),
                    ),
                child: Text("Scan Servers", style: GoogleFonts.inter()),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => const ServerIpSearchPage(),
                      ),
                    ),
                child: Text("Server ip lookup", style: GoogleFonts.inter()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
