import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_scanner/app/screen/server_view.dart';
import 'package:server_scanner/app/utils/toastifications.dart';
import 'package:server_scanner/core/api/api.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchServerView extends StatefulWidget {
  final List serverData;
  final int initialLimit;
  final Map<String, dynamic> query;
  final bool isSavedServerView;
  const SearchServerView({
    super.key,
    required this.serverData,
    required this.initialLimit,
    required this.query,
    this.isSavedServerView = false,
  });

  @override
  State<SearchServerView> createState() => _SearchServerViewState();
}

class _SearchServerViewState extends State<SearchServerView> {
  late int totalShowedServerCount;
  late int totalPages;
  late List serverData;
  bool isLoading = false;
  bool isInitializing = false;
  late int maxResultLimit;
  late int serverCount;
  int currentPage = 1;

  // selected values
  int? selectedIndex;
  String? selectedServerIP;
  int? selectedServerPort;

  @override
  void initState() {
    super.initState();
    totalShowedServerCount = widget.initialLimit;
    totalPages = 1;
    serverData = widget.serverData;
    maxResultLimit = widget.initialLimit;

    if (!widget.isSavedServerView) createPagination();
  }

  Future<void> createPagination() async {
    setState(() {
      isInitializing = true;
    });

    serverCount = await Api().getTotalServerCount(query: widget.query);

    totalPages = (serverCount / maxResultLimit).ceil();
    log(totalPages.toString());
    setState(() {
      isInitializing = false;
    });
  }

  Future<void> showPreviousPage() async {
    setState(() {
      isLoading = true;
    });
    // check if next page is not the first page
    if (currentPage - 1 < 1) {
      CustomToasts().showWarningToast('You are on the first page', context);
      setState(() {
        isLoading = false;
      });
      return;
    }

    serverData.clear();

    currentPage -= 1;
    totalShowedServerCount = maxResultLimit * currentPage;
    selectedIndex = null;

    var data = await Api().searchServer(
      context: context,
      query: widget.query,
      limit: maxResultLimit,
      skip: totalShowedServerCount - maxResultLimit,
      getServerCount: false,
    );

    serverData.addAll(data);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> showNextPage() async {
    setState(() {
      isLoading = true;
    });

    // check if next page is not the last page
    if (currentPage + 1 > totalPages) {
      CustomToasts().showWarningToast('You are on the last page', context);
      setState(() {
        isLoading = false;
      });
      return;
    }

    serverData.clear();
    selectedIndex = null;

    var data = await Api().searchServer(
      context: context,
      query: widget.query,
      limit: maxResultLimit,
      skip: currentPage * maxResultLimit,
      getServerCount: false,
    );

    serverData.addAll(data);

    currentPage += 1;
    totalShowedServerCount = maxResultLimit * currentPage;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NavigationView(
          appBar: NavigationAppBar(title: const Text('Search Server View')),
          content: SafeArea(
            child: Row(
              children: [
                Flexible(
                  flex: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    spacing: 16,
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.06,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isInitializing
                                ? ProgressBar()
                                : !widget.isSavedServerView
                                ? Text(
                                  '${totalShowedServerCount - widget.initialLimit + 1}-${totalShowedServerCount > serverCount ? serverCount : totalShowedServerCount} of $serverCount servers found',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : Text(
                                  "SAVED SERVERS",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ],
                        ),
                      ),
                      Expanded(
                        child:
                            !isLoading
                                ? Center(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: serverData.length,
                                    itemBuilder: (context, index) {
                                      Map data = widget.serverData[index];

                                      String serverIp =
                                          data["port"] == 25565
                                              ? data["ip"]
                                              : "${data["ip"]}:${data["port"]}";
                                      String isCracked =
                                          data["cracked"] == null
                                              ? "N/A"
                                              : data["cracked"]
                                              ? "Yes"
                                              : "No";
                                      String isWhitelist =
                                          data["whitelist"] == null
                                              ? "N/A"
                                              : data["whitelist"]
                                              ? "Yes"
                                              : "No";
                                      String serverVersion =
                                          data["version"]["name"] ?? "N/A";
                                      String lastSeen = timeago.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          data["lastSeen"] * 1000,
                                        ),
                                      );
                                      String playerCount =
                                          '${data["players"]["online"] ?? 0}/${data["players"]["max"] ?? 0}';
                                      String countryName =
                                          data["geo"]?["country"] ?? "N/A";
                                      return ListTile(
                                        tileColor:
                                            selectedIndex != null &&
                                                    selectedIndex == index
                                                ? WidgetStatePropertyAll(
                                                  Colors.grey,
                                                )
                                                : null,
                                        onPressed: () {
                                          setState(() {
                                            selectedServerIP = data["ip"];
                                            selectedServerPort = data["port"];
                                            selectedIndex = index;
                                          });
                                        },
                                        leading: CircleAvatar(
                                          child: Text(
                                            countryName,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(
                                              serverIp,
                                              style: GoogleFonts.inter(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Spacer(),
                                            Text(
                                              lastSeen,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          "Cracked: $isCracked \u2022 Whitelist: $isWhitelist \u2022 Player Count: $playerCount \u2022 Version: $serverVersion}",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w300,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Center(child: ProgressRing()),
                      ),

                      SizedBox(
                        height: constraints.maxHeight * 0.06,

                        child:
                            widget.isSavedServerView
                                ? SizedBox.shrink()
                                : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      FilledButton(
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () async =>
                                                    showPreviousPage(),
                                        child: const Text('Previous Page'),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "$currentPage/$totalPages",
                                          ),
                                        ),
                                      ),
                                      FilledButton(
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () async => showNextPage(),
                                        child: const Text('Next Page'),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:
                        selectedServerIP != null && selectedServerPort != null
                            ? ServerView(
                              key: ValueKey(
                                '$selectedServerIP-$selectedServerPort',
                              ),
                              serverIp: selectedServerIP!,
                              serverPort: selectedServerPort!,
                            )
                            : Center(
                              child: Text(
                                "NO SERVER SELECTED",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
