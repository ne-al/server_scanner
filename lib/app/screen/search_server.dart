// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_scanner/app/screen/search_server_view.dart';
import 'package:server_scanner/app/utils/custom_textfield.dart';
import 'package:server_scanner/app/utils/toastifications.dart';
import 'package:server_scanner/core/api/api.dart';

class SearchServerPage extends StatefulWidget {
  const SearchServerPage({super.key});

  @override
  State<SearchServerPage> createState() => _SearchServerPageState();
}

class _SearchServerPageState extends State<SearchServerPage> {
  final TextEditingController versionNameController = TextEditingController();
  final TextEditingController maxPlayerCountController =
      TextEditingController();
  final TextEditingController minPlayerOnlineCountController =
      TextEditingController();

  List<int> searchLimitList = [10, 25, 50, 100];
  int searchLimit = 10;
  int sliderValue = 0;

  Map<String, dynamic> query = {};

  List serverList = [];

  bool isLoading = false;
  bool isCracked = false;
  bool isWhitelist = false;

  Future<void> searchServer() async {
    setState(() {
      isLoading = true;
    });

    int? maxPlayerCount;
    int? minPlayerOnlineCount;
    String? serverVersionName;
    int? serverLastSeen;

    query = {};

    if (versionNameController.text.trim().isNotEmpty) {
      serverVersionName = versionNameController.text.trim();
    }

    if (maxPlayerCountController.text.trim().isNotEmpty) {
      maxPlayerCount = int.parse(maxPlayerCountController.text.trim());
    }

    if (minPlayerOnlineCountController.text.trim().isNotEmpty) {
      minPlayerOnlineCount = int.parse(
        minPlayerOnlineCountController.text.trim(),
      );
    }

    if (maxPlayerCount != null) {
      final maxPlayerCount0 = <String, dynamic>{"players.max": maxPlayerCount};

      query.addEntries(maxPlayerCount0.entries);
    }

    if (minPlayerOnlineCount != null) {
      final minPlayerOnlineCount0 = <String, dynamic>{
        "players.online": minPlayerOnlineCount,
      };

      query.addEntries(minPlayerOnlineCount0.entries);
    }

    if (serverVersionName != null) {
      final serverVersionName0 = <String, dynamic>{
        "version.name": serverVersionName.toString(),
      };

      query.addEntries(serverVersionName0.entries);
    }

    if (sliderValue != 0) {
      DateTime now = DateTime.now();

      var time = now.subtract(Duration(hours: sliderValue));

      serverLastSeen = time.millisecondsSinceEpoch ~/ 1000;

      final serverLastSeen0 = <String, dynamic>{
        "lastSeen": {"\$gte": serverLastSeen},
      };

      query.addEntries(serverLastSeen0.entries);
    }

    if (isCracked) {
      final cracked = <String, dynamic>{"cracked": isCracked};

      query.addEntries(cracked.entries);
    }

    if (isWhitelist) {
      final whitelist = <String, dynamic>{"whitelist": isWhitelist};

      query.addEntries(whitelist.entries);
    }

    var data = await Api().searchServer(
      context: context,
      query: query,
      limit: searchLimit,
    );

    // Logger().e(data);

    log("QUERY: $query \n SEARCH LIMIT: $searchLimit");

    if (data.isEmpty) {
      CustomToasts().showWarningToast("No server found", context);
    }

    setState(() {
      serverList = data;
      // totalServerCount = data["count"];
      isLoading = false;
    });

    Navigator.push(
      context,
      FluentPageRoute(
        builder:
            (context) => SearchServerView(
              serverData: serverList,
              initialLimit: searchLimit,
              query: query,
            ),
      ),
    );
  }

  @override
  void dispose() {
    versionNameController.dispose();
    maxPlayerCountController.dispose();
    minPlayerOnlineCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NavigationView(
          appBar: NavigationAppBar(
            title: Text('Search Server', style: GoogleFonts.inter()),
          ),
          content: SafeArea(
            child: Center(
              child: SizedBox(
                width:
                    constraints.maxWidth * 0.75 > 400
                        ? 400
                        : constraints.maxWidth * 0.75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  spacing: 12,
                  children: [
                    customTextField(
                      controller: versionNameController,
                      hintText: 'Enter version name eg. 1.21.4',
                    ),
                    customTextField(
                      controller: minPlayerOnlineCountController,
                      hintText: 'Enter current online player. eg. 1',
                    ),
                    customTextField(
                      controller: maxPlayerCountController,
                      hintText: 'Enter max player limit. eg. 20',
                    ),
                    Gap(1),

                    Row(
                      children: [
                        Text('Cracked', style: GoogleFonts.inter()),
                        Spacer(),
                        ToggleSwitch(
                          checked: isCracked,
                          onChanged: (value) {
                            setState(() {
                              isCracked = !isCracked;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Whitelist', style: GoogleFonts.inter()),
                        Spacer(),
                        ToggleSwitch(
                          checked: isWhitelist,
                          onChanged: (value) {
                            setState(() {
                              isWhitelist = !isWhitelist;
                            });
                          },
                        ),
                      ],
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Search Limit", style: GoogleFonts.inter()),
                        Spacer(),
                        ComboBox<int>(
                          value: searchLimit,
                          items:
                              searchLimitList.map<ComboBoxItem<int>>((e) {
                                return ComboBoxItem<int>(
                                  value: e,
                                  child: Text("$e", style: GoogleFonts.inter()),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(() {
                                searchLimit = value!;
                              }),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Text(
                                'Server last seen.',
                                style: GoogleFonts.inter(),
                              ),
                              Spacer(),
                              Text(
                                sliderValue == 0
                                    ? "Any time"
                                    : "$sliderValue hrs ago",
                                style: GoogleFonts.inter(),
                              ),
                            ],
                          ),
                        ),
                        Gap(12),
                        Slider(
                          value: sliderValue.toDouble(),
                          label: sliderValue.toString(),
                          min: 0,
                          max: 12,
                          divisions: 12,
                          onChanged:
                              (value) =>
                                  setState(() => sliderValue = value.toInt()),
                        ),
                      ],
                    ),
                    Gap(2),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: FilledButton(
                        onPressed:
                            isLoading ? null : () async => await searchServer(),
                        child:
                            isLoading
                                ? Center(child: ProgressRing(strokeWidth: 1))
                                : Text('Search'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
