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

  static Future<Map<String, String>> owlracleLegacy({
    required String apiEndpoint,
    required String network,
  }) async {
    final String fees = File('./assets/ethereum.json').readAsStringSync();
    var safeGasPrice = double.parse(jsonDecode(fees)[network]['safeGasPrice']);
    var proposeGasPrice =
        double.parse(jsonDecode(fees)[network]['proposeGasPrice']);
    var fastGasPrice = double.parse(jsonDecode(fees)[network]['fastGasPrice']);
    var gasLimit = double.parse(jsonDecode(fees)[network]['gasLimit']);

    const owlApiKey = String.fromEnvironment('OWL_API_KEY');
    late final Response request;
    if (network == 'matic') {
      request = await getRequest(
          '${apiEndpoint}poly/gas?apikey=$owlApiKey&accept=60%2C90%2C100');
    } else {
      request = await getRequest(
          '$apiEndpoint$network/gas?apikey=$owlApiKey&accept=60%2C90%2C100');
    }
    if (jsonDecode(request.body)['status'] != null) {
      throw Exception(request.body);
    }
    safeGasPrice = jsonDecode(request.body)['speeds'][0]['gasPrice'].toDouble();
    proposeGasPrice =
        jsonDecode(request.body)['speeds'][1]['gasPrice'].toDouble();
    fastGasPrice = jsonDecode(request.body)['speeds'][2]['gasPrice'].toDouble();
    gasLimit = jsonDecode(request.body)['avgGas'].toDouble();

    final prices = {
      'safeGasPrice': (safeGasPrice * pow(10, 9)).round().toString(),
      'proposeGasPrice': (proposeGasPrice * pow(10, 9)).round().toString(),
      'fastGasPrice': (fastGasPrice * pow(10, 9)).round().toString(),
      'gasLimit': gasLimit.round().toString(),
    };
    return prices;
  }

  static Future<Map<String, String>> owlracleEIP1559({
    required String apiEndpoint,
    required String network,
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
    var gasLimit = double.parse(jsonDecode(fees)[network]['gasLimit']);

    const owlApiKey = String.fromEnvironment('OWL_API_KEY');
    late final Response request;
    if (network == 'matic') {
      request = await getRequest(
          '${apiEndpoint}poly/gas?apikey=$owlApiKey&accept=60%2C90%2C100');
    } else {
      request = await getRequest(
          '$apiEndpoint$network/gas?apikey=$owlApiKey&accept=60%2C90%2C100');
    }
    if (jsonDecode(request.body)['status'] != null) {
      throw Exception(request.body);
    }
    safeMaxFeePerGas =
        jsonDecode(request.body)['speeds'][0]['gasPrice'].toDouble();
    proposeMaxFeePerGas =
        jsonDecode(request.body)['speeds'][1]['gasPrice'].toDouble();
    fastMaxFeePerGas =
        jsonDecode(request.body)['speeds'][2]['gasPrice'].toDouble();
    safeMaxInclusionFeePerGas =
        (safeMaxFeePerGas - jsonDecode(request.body)['baseFee'].toDouble()) *
            pow(10, 9);
    proposeMaxInclusionFeePerGas =
        (proposeMaxFeePerGas - jsonDecode(request.body)['baseFee'].toDouble()) *
            pow(10, 9);
    fastMaxInclusionFeePerGas =
        (fastMaxFeePerGas - jsonDecode(request.body)['baseFee'].toDouble()) *
            pow(10, 9);
    gasLimit = jsonDecode(request.body)['avgGas'].toDouble();

    final prices = {
      'safeMaxInclusionFeePerGas': safeMaxInclusionFeePerGas.round().toString(),
      'proposeMaxInclusionFeePerGas':
          proposeMaxInclusionFeePerGas.round().toString(),
      'fastMaxInclusionFeePerGas': fastMaxInclusionFeePerGas.round().toString(),
      'safeMaxFeePerGas': (safeMaxFeePerGas * pow(10, 9)).round().toString(),
      'proposeMaxFeePerGas':
          (proposeMaxFeePerGas * pow(10, 9)).round().toString(),
      'fastMaxFeePerGas': (fastMaxFeePerGas * pow(10, 9)).round().toString(),
      'gasLimit': gasLimit.round().toString(),
    };
    return prices;
  }
}
