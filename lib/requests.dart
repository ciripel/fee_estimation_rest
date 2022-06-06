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
  static Future<Map<String, String>> get eth async {
    final String ethereumFees =
        File('./assets/ethereum.json').readAsStringSync();
    String safeGasPrice = jsonDecode(ethereumFees)['eth']['safeGasPrice'];
    String proposeGasPrice = jsonDecode(ethereumFees)['eth']['proposeGasPrice'];
    String fastGasPrice = jsonDecode(ethereumFees)['eth']['fastGasPrice'];

    final request = await getRequest(
        'https://api.etherscan.io/api?module=gastracker&action=gasoracle');
    if (jsonDecode(request.body)['status'] != '1') {
      throw Exception(request.body);
    }
    safeGasPrice = jsonDecode(request.body)['result']['SafeGasPrice'];
    proposeGasPrice = jsonDecode(request.body)['result']['ProposeGasPrice'];
    fastGasPrice = jsonDecode(request.body)['result']['FastGasPrice'];
    final eth = {
      'safeGasPrice': '${safeGasPrice}000000000',
      'proposeGasPrice': '${proposeGasPrice}000000000',
      'fastGasPrice': '${fastGasPrice}000000000',
      'gasLimit': '21000',
    };
    return eth;
  }

  static Future<Map<String, String>> get bsc async {
    final String ethereumFees =
        File('./assets/ethereum.json').readAsStringSync();
    String safeGasPrice = jsonDecode(ethereumFees)['bsc']['safeGasPrice'];
    String proposeGasPrice = jsonDecode(ethereumFees)['bsc']['proposeGasPrice'];
    String fastGasPrice = jsonDecode(ethereumFees)['bsc']['fastGasPrice'];

    final request = await getRequest(
        'https://api.bscscan.com/api?module=gastracker&action=gasoracle');
    if (jsonDecode(request.body)['status'] != '1') {
      throw Exception(request.body);
    }
    safeGasPrice = jsonDecode(request.body)['result']['SafeGasPrice'];
    proposeGasPrice = jsonDecode(request.body)['result']['ProposeGasPrice'];
    fastGasPrice = jsonDecode(request.body)['result']['FastGasPrice'];
    final bsc = {
      'safeGasPrice': '${safeGasPrice}000000000',
      'proposeGasPrice': '${proposeGasPrice}000000000',
      'fastGasPrice': '${fastGasPrice}000000000',
      'gasLimit': '21000',
    };
    return bsc;
  }
}
