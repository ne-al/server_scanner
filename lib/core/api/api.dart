// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:server_scanner/app/utils/toastifications.dart';

class Api {
  final baseUrl = "https://api.cornbread2100.com";

  // search server with query
  Future<List> searchServer({
    required BuildContext context,
    required Map<String, dynamic> query,
    required int limit,
    int skip = 0,
    bool getServerCount = true,
  }) async {
    String encodedQuery = await encodeQuery(query);

    Uri url = Uri.parse(
      "$baseUrl/servers?limit=$limit&skip=$skip&query=$encodedQuery",
    );
    log(url.toString());
    try {
      // Start both asynchronous operations concurrently.
      Future<http.Response> responseFuture = http.get(url);
      // Future<int> countFuture =
      //     getServerCount
      //         ? getTotalServerCount(query: encodedQuery)
      //         : Future.value(0);

      // Await the HTTP response first, then the server count.
      final response = await responseFuture;
      // final serverCount = await countFuture;

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        // getServerCount
        //     ? CustomToasts().showSuccessToast(
        //       "Successfully loaded ${serverCount.toString()} servers",
        //       context,
        //     )
        //     : null;
        // return {"results": data, "count": serverCount,};

        return data;
      } else {
        CustomToasts().showErrorToast(
          "Failed to load servers\nError: Status code: ${response.statusCode}",
          context,
        );
        throw Exception(
          "Failed to load servers\nError: Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      CustomToasts().showErrorToast(
        "Failed to load servers\nError: $e",
        context,
      );
      throw Exception("Failed to load servers\nError: $e");
    }
  }

  // get total server count with query
  Future<int> getTotalServerCount({required Map<String, dynamic> query}) async {
    String encodedQuery = await encodeQuery(query);

    Uri url = Uri.parse("$baseUrl/count?query=$encodedQuery");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data.toInt();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // get a single server with server ip and port
  Future<Map<String, dynamic>> getServer({
    required String ip,
    required int port,
  }) async {
    Map<String, dynamic> query = {"ip": ip, "port": port};

    String encodedQuery = await encodeQuery(query);

    Uri url = Uri.parse("$baseUrl/servers?query=$encodedQuery");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data[0];
      }
    } catch (e) {
      throw Exception("Failed to load server\nError: $e");
    }
    return {};
  }

  Future<String> encodeQuery(Map<String, dynamic> query) async {
    final String jsonString = jsonEncode(query);
    final String encodedQuery = Uri.encodeQueryComponent(jsonString);
    return encodedQuery;
  }
}
