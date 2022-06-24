import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

import 'borsh/borsh_extensions.dart';
import 'classes/dtos.dart';
import 'constants.dart';
import 'pda.dart';

Future<String?> fetchSolanaNameServiceName(
    SolanaEnvironment environment, String publicKey) async {
  try {
    final url = urlMap[environment]!;
    if (publicKey.isNotEmpty) {
      final address = Ed25519HDPublicKey.fromBase58(publicKey);
      var domainName = await findFavoriteDomainName(environment, address);
      if (domainName?.isNotEmpty != true) {
        final domainKeys =
            await findOwnedNameAccountsForUser(environment, address);
        domainKeys.sort((a, b) => a.toBase58().compareTo(b.toBase58()));
        for (var domainKey in domainKeys) {
          domainName = await performReverseLookup(url, domainKey);
          if (domainName != null) {
            return domainName;
          }
        }
      }
    }
  } catch (e) {
    print(e);
  }
  return null;
}

Future<Ed25519HDPublicKey?> findAccountByName(
    SolanaEnvironment environment, String name) async {
  final hashedName = await getHashedName(name);
  final key = await getNameAccountKey(hashedName, null, SOL_TLD_AUTHORITY);
  final registryAccount = await RpcClient(urlMap[environment]!)
      .getAccountInfo(key.toBase58(), encoding: Encoding.base64);
  if (registryAccount?.data == null) return null;
  final registry = parseBytesFromAccount(
      registryAccount, NameRegistryState.fromBorsh,
      skip: 0);
  return registry.owner;
}

Future<String?> findFavoriteDomainName(
    SolanaEnvironment environment, Ed25519HDPublicKey owner) async {
  try {
    final url = urlMap[environment]!;
    final client = RpcClient(url);
    final favoriteKey =
        await getBonfidaSNSProgramAddress(NAME_OFFERS_ID, owner);
    final favoriteAccount = await client.getAccountInfo(favoriteKey.toBase58(),
        encoding: Encoding.base64);
    if (favoriteAccount?.data == null) {
      return null;
    }
    final favoriteDomain = parseBytesFromAccount(
        favoriteAccount, FavoriteDomain.fromBorsh,
        skip: 0);

    return await performReverseLookup(url, favoriteDomain.nameAccount);
  } catch (e) {
    print(e);
  }
  return null;
}

Future<List<Ed25519HDPublicKey>> findOwnedNameAccountsForUser(
    SolanaEnvironment environment, Ed25519HDPublicKey userAccount) async {
  final List<ProgramDataFilter> filters = [
    ProgramDataFilter.memcmp(offset: 32, bytes: userAccount.bytes)
  ];
  final accounts = await RpcClient(urlMap[environment]!).getProgramAccounts(
      NAME_PROGRAM_ID.toBase58(),
      encoding: Encoding.base64,
      filters: filters);
  return accounts.map((e) => Ed25519HDPublicKey.fromBase58(e.pubkey)).toList();
}

Uint8List getHashedName(String name) {
  final input = HASH_PREFIX + name;
  final encodedStr = utf8.encode(input);
  final convertedStr = sha256.convert(encodedStr);
  return Uint8List.fromList(convertedStr.bytes);
}

Future<Ed25519HDPublicKey> getNameAccountKey(Uint8List hashedName,
    Ed25519HDPublicKey? nameClass, Ed25519HDPublicKey? nameParent) {
  var seeds = [hashedName];
  if (nameClass != null) {
    seeds.add(Uint8List.fromList(nameClass.bytes));
  } else {
    seeds.add(Uint8List(32));
  }
  if (nameParent != null) {
    seeds.add(Uint8List.fromList(nameParent.bytes));
  } else {
    seeds.add(Uint8List(32));
  }
  return Ed25519HDPublicKey.findProgramAddress(
      seeds: seeds, programId: NAME_PROGRAM_ID);
}

Future<String?> performReverseLookup(
    String url, Ed25519HDPublicKey nameAccount) async {
  final hashedReverseLookup = getHashedName(nameAccount.toBase58());
  final reverseLookupAccount =
      await getNameAccountKey(hashedReverseLookup, REVERSE_LOOKUP_CLASS, null);

  final registryAccount = await RpcClient(url).getAccountInfo(
      reverseLookupAccount.toBase58(),
      encoding: Encoding.base64);
  if (registryAccount?.data == null) return null;
  final registry = parseBytesFromAccount(
      registryAccount, NameRegistryState.fromBorsh,
      skip: 0);
  return registry.name;
}
