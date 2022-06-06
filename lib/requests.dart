import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

Future<Response> getRequest(String apiEndpoint) async {
  return get(
    Uri.parse(apiEndpoint),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

class GasPrice {
  static Future<Map<String, String>> scan({
    required String apiEndpoint,
    required String network,
    String gaslimit = '21000',
  }) async {
    final String fees = File('./assets/ethereum.json').readAsStringSync();
    String safeGasPrice = jsonDecode(fees)[network]['safeGasPrice'];
    String proposeGasPrice = jsonDecode(fees)[network]['proposeGasPrice'];
    String fastGasPrice = jsonDecode(fees)[network]['fastGasPrice'];

    final request = await getRequest(
        '${apiEndpoint}api?module=gastracker&action=gasoracle');
    if (jsonDecode(request.body)['status'] != '1') {
      throw Exception(request.body);
    }
    safeGasPrice = jsonDecode(request.body)['result']['SafeGasPrice'];
    proposeGasPrice = jsonDecode(request.body)['result']['ProposeGasPrice'];
    fastGasPrice = jsonDecode(request.body)['result']['FastGasPrice'];
    final prices = {
      'safeGasPrice': '${safeGasPrice}000000000',
      'proposeGasPrice': '${proposeGasPrice}000000000',
      'fastGasPrice': '${fastGasPrice}000000000',
      'gasLimit': gaslimit,
    };
    return prices;
  }
}
