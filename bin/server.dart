import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fee_estimation_rest/requests.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/cosmos', _getCosmosFeesHandler)
  ..get('/ethereum', _getEthereumFeesHandler)
  ..get('/solana', _getSolanaFeesHandler)
  ..get('/utxoCoins', _getUtxoCoinsFeesHandler);

Response _rootHandler(Request req) {
  return Response.ok('Check /cosmos for cosmos chainId and minFee and gas\n'
      'Check /ethereum for ethereum gasPrice and gasLimit\n'
      'Check /solana for solana fee\n'
      'Check /utxoCoins for utxoCoins minByteFee\n');
}

Response _getCosmosFeesHandler(Request request) {
  String cosmosFees = File('./assets/cosmos.json').readAsStringSync();
  return Response.ok(cosmosFees);
}

Response _getEthereumFeesHandler(Request request) {
  String ethereumFees = File('./assets/ethereum.json').readAsStringSync();
  return Response.ok(ethereumFees);
}

Response _getSolanaFeesHandler(Request request) {
  String solanaFees = File('./assets/solana.json').readAsStringSync();
  return Response.ok(solanaFees);
}

Response _getUtxoCoinsFeesHandler(Request request) {
  String utxoCoinsFees = File('./assets/utxo_coins.json').readAsStringSync();
  return Response.ok(utxoCoinsFees);
}

void main(List<String> args) async {
  Timer.periodic(Duration(minutes: 5), (timer) async {
    try {
      Map<String, dynamic> fees =
          jsonDecode(File('./assets/ethereum.json').readAsStringSync());
      fees['bsc'] = await GasPrice.owlracleLegacy(
        apiEndpoint: 'https://owlracle.info/',
        network: 'bsc',
      );
      fees['eth'] = await GasPrice.owlracleEIP1559(
        apiEndpoint: 'https://owlracle.info/',
        network: 'eth',
      );
      fees['matic'] = await GasPrice.owlracleEIP1559(
        apiEndpoint: 'https://owlracle.info/',
        network: 'matic',
      );
      fees['avax'] = await GasPrice.owlracleEIP1559(
        apiEndpoint: 'https://owlracle.info/',
        network: 'avax',
      );
      await File('./assets/ethereum.json')
          .writeAsString(JsonEncoder.withIndent('  ').convert(fees));
    } catch (error) {
      print(error);
    }
  });
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
