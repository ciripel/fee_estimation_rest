import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
  });

  tearDown(() => p.kill());

  test('Root', () async {
    final response = await get(Uri.parse('$host/'));
    expect(response.statusCode, 200);
    expect(
        response.body,
        'Check /cosmos for cosmos chainId and minFee and gas\n'
        'Check /ethereum for ethereum gasPrice and gasLimit\n'
        'Check /utxoCoins for utxoCoins minByteFee\n');
  });

  test('Cosmos', () async {
    final response = await get(Uri.parse('$host/cosmos'));
    expect(response.statusCode, 200);
    String cosmosFees = File('./assets/cosmos.json').readAsStringSync();
    expect(response.body, cosmosFees);
  });

  test('Ethereum', () async {
    final response = await get(Uri.parse('$host/ethereum'));
    expect(response.statusCode, 200);
    String ethereumFees = File('./assets/ethereum.json').readAsStringSync();
    expect(response.body, ethereumFees);
  });

  test('utxoCoins', () async {
    final response = await get(Uri.parse('$host/utxoCoins'));
    expect(response.statusCode, 200);
    String utxoCoinsFees = File('./assets/utxo_coins.json').readAsStringSync();
    expect(response.body, utxoCoinsFees);
  });

  test('404', () async {
    final response = await get(Uri.parse('$host/foobar'));
    expect(response.statusCode, 404);
  });
}
