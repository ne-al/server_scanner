import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_scanner/app/screen/server_view.dart';
import 'package:server_scanner/app/utils/custom_textfield.dart';

class ServerIpSearchPage extends StatefulWidget {
  const ServerIpSearchPage({super.key});

  @override
  State<ServerIpSearchPage> createState() => _ServerIpSearchPageState();
}

class _ServerIpSearchPageState extends State<ServerIpSearchPage> {
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  bool isLoading = false;
  late Map<String, dynamic> serverData;

  // selected values
  String? serverIP;
  int? serverPort;

  @override
  void initState() {
    super.initState();
    portController.text = '25565';
  }

  Future<void> lookup() async {
    setState(() {
      isLoading = true;
    });

    // serverData = await Api().getServer(
    //   ip: ipController.text.trim(),
    //   port: int.parse(portController.text.trim()),
    // );

    if (ipController.text.trim().isEmpty) return;
    if (portController.text.trim().isEmpty) {
      portController.text = '25565';
    }

    serverIP = ipController.text.trim();
    serverPort = int.parse(portController.text.trim());

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NavigationView(
          appBar: NavigationAppBar(title: const Text('Server IP Search')),
          content: SafeArea(
            child: Row(
              children: [
                Flexible(
                  flex: 3,
                  child: Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.35,
                      child: Column(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customTextField(
                            controller: ipController,
                            hintText: "Enter Server IP",
                          ),
                          customTextField(
                            controller: portController,
                            hintText: "Enter Server Port",
                          ),

                          FilledButton(
                            onPressed:
                                isLoading ? null : () async => await lookup(),
                            child: Text("Lookup", style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child:
                      !isLoading && serverIP != null && serverPort != null
                          ? ServerView(
                            key: ValueKey("${serverIP!}-${serverPort!}"),
                            serverIp: serverIP!,
                            serverPort: serverPort!,
                          )
                          : Center(child: Text("No Server Selected")),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
