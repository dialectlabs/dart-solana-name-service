import 'package:flutter_test/flutter_test.dart';
import 'package:solana/solana.dart';
import 'package:solana_name_service/src/sns.dart';

void main() {
  group('Solana name service', () {
    const baseUrl = "https://api.mainnet-beta.solana.com";
    print("testing with URL: $baseUrl");

    test('Find owned accounts succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      var accts = await findOwnedNameAccountsForUser(baseUrl, pubKey);
      expect(accts.length, equals(1));
    });

    test('Reverse lookup success', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      final name = await fetchSolanaNameServiceName(baseUrl, pubKey.toBase58());
      expect(name, equals("dialect"));
    });

    test('Find favorite domain name succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      final name = await findFavoriteDomainName(baseUrl, pubKey);

      // TODO - set dialect favorite name
      print("Found name: $name");
      // for now, edit the file to test with your own address and associated favorite name
      // expect(name, equals(""));
    });
  });
}
