/// Flags the app and every framework that does not contain a privacy manifest.
package struct MissingPrivacyManifestRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "missing-privacy-manifest",
        category: .review,
        defaultSeverity: .warning,
        summary: "The app or a framework has no PrivacyInfo.xcprivacy.",
    )

    package init() {}

    /// Flags the app when `PrivacyInfo.xcprivacy` is not at its root, and each framework with no manifest anywhere
    /// inside it. SwiftPM-built SDKs keep theirs in a nested `<Name>_Privacy.bundle`, while resource bundles at the
    /// app root belong to packages, not to the app.
    package func check(_ context: RuleContext) -> [RuleHit] {
        let manifests = context.contents.files.map(\.path).filter { $0.split(separator: "/").last == "PrivacyInfo.xcprivacy" }
        return context.contents.bundles
            .filter { $0.path.isEmpty || $0.kind == .framework }
            .filter { !Self.hasManifest($0, manifests: manifests) }
            .map {
                RuleHit(
                    path: $0.displayPath,
                    message: "No PrivacyInfo.xcprivacy. App Store Connect requires privacy manifests for the app and for commonly used third-party SDKs; add one, or update the SDK to a version that includes it.",
                )
            }
    }

    private static func hasManifest(_ bundle: EmbeddedBundle, manifests: [String]) -> Bool {
        if bundle.path.isEmpty {
            return manifests.contains("PrivacyInfo.xcprivacy")
        }
        return manifests.contains { $0.hasPrefix(bundle.path + "/") }
    }
}
