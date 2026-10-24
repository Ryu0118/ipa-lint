import Foundation

/// Flags key and credential files that ended up in the app.
package struct CredentialFileRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "credential-file",
        category: .security,
        defaultSeverity: .error,
        summary: "The app contains a private key, certificate, .env file, or provisioning profile that must not be distributed.",
    )

    private static let extensions: Set<String> = ["p8", "p12", "pfx", "pem", "key", "jks", "keystore"]
    private static let names: Set<String> = [".env", ".netrc", "id_rsa", "id_ecdsa", "id_ed25519"]

    package init() {}

    /// Returns one hit for every file that looks like a key or credential.
    package func check(_ context: RuleContext) -> [RuleHit] {
        context.contents.files.compactMap { file in
            guard let kind = Self.credentialKind(of: file.path) else {
                return nil
            }
            return RuleHit(path: file.path, message: "\(kind) must not ship in the app; remove it from the bundle resources and rotate it if it was ever distributed.")
        }
    }

    private static func credentialKind(of path: String) -> String? {
        let components = path.split(separator: "/").map(String.init)
        guard let name = components.last?.lowercased() else {
            return nil
        }
        let fileExtension = URL(filePath: name).pathExtension
        if fileExtension == "mobileprovision" {
            return isEmbeddedProfile(name: name, parent: components.dropLast().last) ? nil : "A provisioning profile"
        }
        if extensions.contains(fileExtension) || names.contains(name) || name.hasPrefix(".env.") {
            return "A key or credential file (\(name))"
        }
        return nil
    }

    private static func isEmbeddedProfile(name: String, parent: String?) -> Bool {
        guard name == "embedded.mobileprovision" else {
            return false
        }
        guard let parent else {
            return true
        }
        return parent.lowercased().hasSuffix(".appex") || parent.lowercased().hasSuffix(".app")
    }
}
