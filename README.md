
[![Twitter Follow](https://img.shields.io/twitter/follow/saydialect?style=social)](https://twitter.com/saydialect)
[![Discord](https://img.shields.io/discord/944285706963017758?label=Discord)](https://discord.gg/cxtZVyrJ)

## Dart library for Bonfida SNS

This library is a partial dart implementation of Bonfida's SNS (Solana Name Service) protocol, specifically enabling the use of .sol domains in Flutter applications.

## Implementation

1. Find all Bonfida SNS name registration accounts for a given user

    ```dart
    final List<PublicKey> accounts = await findOwnedNameAccountsForUser(
        environment: SolanaEnvironment, // mainnet | devnet | localnet
        publicKey: PublicKey // user account to query
    );
    ```

2. Return a given user's SNS domain name

    ```dart
    final String name = await fetchSolanaNameServiceName(
        environment: SolanaEnvironment, // mainnet | devnet | localnet
        publicKey: String // user account to query as a string
    );
    ```

3. Return a given user's favorite SNS domain name

    ```dart
    final String name = await findFavoriteDomainName(
        environment: SolanaEnvironment, // mainnet | devnet | localnet
        publicKey: PublicKey // user account to query
    );
    ```

4. Return an SNS domain name owner's public key

    ```dart
    final PublicKey publicKey = await findAccountByName(
        environment: SolanaEnvironment, // mainnet | devnet | localnet
        name: String // SNS domain name
    );
    ```

5. Return the SNS domain name associated with a given SNS name registration account

    ```dart
    final String name = await performReverseLookup(
        environment: SolanaEnvironment, // mainnet | devnet | localnet
        account: PublicKey // SNS name registration account to query
    );
    ```


## Further Help & Documentation

We will continue to update documentation as often as possible. But if you need help, feel free to reach out in our [Dialect Discord server](https://discord.gg/cxtZVyrJ).