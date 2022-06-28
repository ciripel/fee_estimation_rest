import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
  static Future<Map<String, String>> scanLegacy({
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

  static Future<Map<String, String>> scanEIP1559({
    required String apiEndpoint,
    required String network,
    String gaslimit = '21000',
  }) async {
    final String fees = File('./assets/ethereum.json').readAsStringSync();
    var safeMaxInclusionFeePerGas =
        double.parse(jsonDecode(fees)[network]['safeMaxInclusionFeePerGas']);
    var proposeMaxInclusionFeePerGas =
        double.parse(jsonDecode(fees)[network]['proposeMaxInclusionFeePerGas']);
    var fastMaxInclusionFeePerGas =
        double.parse(jsonDecode(fees)[network]['fastMaxInclusionFeePerGas']);
    var safeMaxFeePerGas =
        double.parse(jsonDecode(fees)[network]['safeMaxFeePerGas']);
    var proposeMaxFeePerGas =
        double.parse(jsonDecode(fees)[network]['proposeMaxFeePerGas']);
    var fastMaxFeePerGas =
        double.parse(jsonDecode(fees)[network]['fastMaxFeePerGas']);

    final request = await getRequest(
        '${apiEndpoint}api?module=gastracker&action=gasoracle');
    if (jsonDecode(request.body)['status'] != '1') {
      throw Exception(request.body);
    }
    safeMaxFeePerGas =
        double.parse(jsonDecode(request.body)['result']['SafeGasPrice']);
    proposeMaxFeePerGas =
        double.parse(jsonDecode(request.body)['result']['ProposeGasPrice']);
    fastMaxFeePerGas =
        double.parse(jsonDecode(request.body)['result']['FastGasPrice']);
    safeMaxInclusionFeePerGas = ((safeMaxFeePerGas -
            double.parse(
                jsonDecode(request.body)['result']['suggestBaseFee'])) *
        pow(10, 9));
    proposeMaxInclusionFeePerGas = ((proposeMaxFeePerGas -
            double.parse(
                jsonDecode(request.body)['result']['suggestBaseFee'])) *
        pow(10, 9));
    fastMaxInclusionFeePerGas = ((fastMaxFeePerGas -
            double.parse(
                jsonDecode(request.body)['result']['suggestBaseFee'])) *
        pow(10, 9));

    final prices = {
      'safeMaxInclusionFeePerGas': safeMaxInclusionFeePerGas.round().toString(),
      'proposeMaxInclusionFeePerGas':
          proposeMaxInclusionFeePerGas.round().toString(),
      'fastMaxInclusionFeePerGas': fastMaxInclusionFeePerGas.round().toString(),
      'safeMaxFeePerGas': (safeMaxFeePerGas * pow(10, 9)).round().toString(),
      'proposeMaxFeePerGas':
          (proposeMaxFeePerGas * pow(10, 9)).round().toString(),
      'fastMaxFeePerGas': (fastMaxFeePerGas * pow(10, 9)).round().toString(),
      'gasLimit': gaslimit,
    };
    return prices;
  }
}
