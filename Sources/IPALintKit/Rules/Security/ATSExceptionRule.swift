/// Flags App Transport Security settings that allow unencrypted or unvalidated connections.
package struct ATSExceptionRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "ats-exception",
        category: .security,
        defaultSeverity: .error,
        summary: "Info.plist weakens App Transport Security with arbitrary-loads or insecure-HTTP exceptions.",
    )

    private static let arbitraryLoadKeys = ["NSAllowsArbitraryLoads", "NSAllowsArbitraryLoadsInWebContent", "NSAllowsArbitraryLoadsForMedia"]
    private static let insecureHTTPKeys = ["NSExceptionAllowsInsecureHTTPLoads", "NSTemporaryExceptionAllowsInsecureHTTPLoads"]

    package init() {}

    /// Returns one hit per enabled arbitrary-loads key and per domain that allows insecure HTTP.
    package func check(_ context: RuleContext) -> [RuleHit] {
        context.contents.bundles.flatMap(hits(in:))
    }

    private func hits(in bundle: EmbeddedBundle) -> [RuleHit] {
        guard let ats = bundle.infoPlist["NSAppTransportSecurity"]?.dictionaryValue else {
            return []
        }
        let path = bundle.childPath("Info.plist")
        let arbitrary = Self.arbitraryLoadKeys.filter { ats[$0]?.boolValue == true }.map { key in
            RuleHit(path: path, message: "\(key) is true, which turns off App Transport Security; remove it and add exceptions only for the specific domains you need.")
        }
        let domains = ats["NSExceptionDomains"]?.dictionaryValue ?? [:]
        let insecure = domains.keys.sorted().filter { isInsecure(domains[$0]) }.map { domain in
            RuleHit(path: path, message: "NSExceptionDomains allows insecure HTTP loads for \(domain); serve the domain over HTTPS and remove the exception.")
        }
        return arbitrary + insecure
    }

    private func isInsecure(_ domain: PlistValue?) -> Bool {
        guard let settings = domain?.dictionaryValue else {
            return false
        }
        return Self.insecureHTTPKeys.contains { settings[$0]?.boolValue == true }
    }
}
