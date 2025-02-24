// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:server_scanner/app/utils/toastifications.dart';
import 'package:server_scanner/core/api/api.dart';
import 'package:timeago/timeago.dart' as timeago;

class ServerView extends StatefulWidget {
  final String serverIp;
  final int serverPort;
  const ServerView({
    super.key,
    required this.serverIp,
    required this.serverPort,
  });

  @override
  State<ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {
  late Map<String, dynamic> serverData;
  bool isLoading = false;
  late String ip;
  late String lastSeen;
  List sortedPlayers = [];
  late String versionName;
  late String isCracked;
  late String isWhiteListed;
  late String countryName;

  @override
  void initState() {
    super.initState();
    getServerData();
  }

  Future<void> getServerData() async {
    setState(() {
      isLoading = true;
    });

    var data = await Api().getServer(
      ip: widget.serverIp,
      port: widget.serverPort,
    );

    if (data.isNotEmpty) {
      serverData = data;

      ip =
          serverData["port"] == 25565
              ? serverData["ip"]
              : "${serverData["ip"]}:${serverData["port"]}";

      lastSeen = timeago.format(
        DateTime.fromMillisecondsSinceEpoch(serverData["lastSeen"] * 1000),
      );

      if (serverData["players"]?["sample"] != null) {
        List players = serverData["players"]?["sample"];

        sortedPlayers =
            players.where((player) {
              return player["id"] != "00000000-0000-0000-0000-000000000000" &&
                  !player["name"].contains("§");
            }).toList();

        // Step 2: Sort the filtered list by 'lastSeen' in descending order
        sortedPlayers.sort((a, b) => b["lastSeen"].compareTo(a["lastSeen"]));
      }

      versionName = serverData["version"]["name"];
      countryName = serverData["geo"]["country"];
      isCracked = serverData["cracked"] ? "Yes" : "No";
      isWhiteListed = serverData["whitelist"] ? "Yes" : "No";
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: SafeArea(
        child: Center(
          child:
              isLoading
                  ? const ProgressRing()
                  : serverData.isEmpty
                  ? const Text("No data")
                  : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  FluentTheme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 6,
                              children: [
                                HoverButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: ip),
                                    );

                                    CustomToasts().showSuccessToast(
                                      "Copied to clipboard",
                                      context,
                                    );
                                  },
                                  builder:
                                      (p0, state) => Text(
                                        "Server IP: $ip",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                          wordSpacing: 1,
                                        ),
                                      ),
                                ),
                                Text(
                                  "Last seen: $lastSeen",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    wordSpacing: 1,
                                  ),
                                ),
                                Text(
                                  "Version: $versionName",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    wordSpacing: 1,
                                  ),
                                ),
                                Text(
                                  "Country: $countryName",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    wordSpacing: 1,
                                  ),
                                ),
                                Text(
                                  "Cracked: $isCracked",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    wordSpacing: 1,
                                  ),
                                ),
                                Text(
                                  "Whitelist: $isWhiteListed",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    wordSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(1),
                          sortedPlayers.isNotEmpty
                              ? Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color:
                                        FluentTheme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Players (${sortedPlayers.length})",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                              wordSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Gap(12),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: sortedPlayers.length,
                                          itemBuilder: (context, index) {
                                            String lastSeen = timeago.format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                sortedPlayers[index]["lastSeen"] *
                                                    1000,
                                              ),
                                            );
                                            return ListTile(
                                              leading: CircleAvatar(
                                                child: Icon(Iconsax.user),
                                              ),
                                              title: Text(
                                                sortedPlayers[index]["name"],
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                  wordSpacing: 1,
                                                ),
                                              ),
                                              subtitle: Text(
                                                sortedPlayers[index]["id"],
                                              ),
                                              trailing: Text(lastSeen),
                                              onPressed: () async {
                                                await Clipboard.setData(
                                                  ClipboardData(
                                                    text:
                                                        sortedPlayers[index]["name"],
                                                  ),
                                                );

                                                CustomToasts().showSuccessToast(
                                                  "Username (${sortedPlayers[index]["name"]}) has been copied to your clipboard",
                                                  context,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color:
                                        FluentTheme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "NO PLAYER DATA FOUND!!",
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
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
