// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:server_scanner/app/utils/toastifications.dart';

class SaveService {
  Box savedServers = Hive.box('servers');

  // save server
  Future<void> saveServer({
    required Map<String, dynamic> serverData,
    required BuildContext context,
  }) async {
    String serverId = "${serverData["ip"]}:${serverData["port"]}";

    try {
      await savedServers.put(serverId, serverData);
      CustomToasts().showSuccessToast('Successfully saved server', context);
    } catch (e) {
      CustomToasts().showErrorToast('Failed to save server', context);
      throw Exception("Failed to save server\nError: $e");
    }
  }

  // remove server
  Future<void> removeServer({
    required String serverId,
    required BuildContext context,
  }) async {
    try {
      await savedServers.delete(serverId);
      CustomToasts().showSuccessToast('Successfully removed server', context);
    } catch (e) {
      CustomToasts().showErrorToast('Failed to remove server', context);
      throw Exception("Failed to remove server\nError: $e");
    }
  }

  // check if current server is saved
  bool isServerSaved(String serverId) => savedServers.containsKey(serverId);

  // get all saved server
}
