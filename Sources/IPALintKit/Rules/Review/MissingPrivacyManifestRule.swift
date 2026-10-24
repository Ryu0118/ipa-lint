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

    /// Flags each bundle whose directory has no `PrivacyInfo.xcprivacy` directly inside it.
    package func check(_ context: RuleContext) -> [RuleHit] {
        let paths = Set(context.contents.files.map(\.path))
        return context.contents.bundles
            .filter { $0.path.isEmpty || $0.kind == .framework }
            .filter { !paths.contains($0.childPath("PrivacyInfo.xcprivacy")) }
            .map {
                RuleHit(
                    path: $0.displayPath,
                    message: "No PrivacyInfo.xcprivacy. App Store Connect requires privacy manifests for the app and for commonly used third-party SDKs; add one, or update the SDK to a version that includes it.",
                )
            }
    }
}
