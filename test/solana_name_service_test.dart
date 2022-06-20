import 'package:flutter_test/flutter_test.dart';
import 'package:solana/solana.dart';
import 'package:solana_name_service/solana_name_service.dart';

void main() {
  group('Solana name service', () {
    const environment = SolanaEnvironment.mainnet;
    print("testing with URL: ${urlMap[environment]}");

    test('Find owned accounts succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      var accts = await findOwnedNameAccountsForUser(environment, pubKey);
      expect(accts.length, equals(1));
    });

    test('Reverse lookup success', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      final name =
          await fetchSolanaNameServiceName(environment, pubKey.toBase58());
      expect(name, equals("dialect"));
    });

    test('Find favorite domain name succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      final name = await findFavoriteDomainName(environment, pubKey);

      // TODO - set dialect favorite name
      print("Found name: $name");
      // for now, edit the file to test with your own address and associated favorite name
      // expect(name, equals(""));
    });
  });
}
