/// Flags API keys, tokens, and private keys found in the strings of the app's files.
package struct EmbeddedSecretRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "embedded-secret",
        category: .security,
        defaultSeverity: .error,
        summary: "A file contains a string that looks like a secret (cloud key, access token, or private key).",
    )

    package init() {}

    /// Returns one hit per file and secret kind, showing only a redacted prefix of the match.
    package func check(_ context: RuleContext) -> [RuleHit] {
        ScannableText.texts(in: context).flatMap { path, text in
            SecretPattern.all.compactMap { pattern in
                pattern.firstMatch(in: text).map { match in
                    RuleHit(
                        path: path,
                        message: "Found a \(pattern.name) (\(match.prefix(4))…); rotate the secret and keep it on a server instead of in the app.",
                    )
                }
            }
        }
    }
}
