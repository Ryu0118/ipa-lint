/// Flags entitlements that a bundle adds or changes compared with the baseline snapshot.
package struct NewEntitlementRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "new-entitlement",
        category: .baseline,
        defaultSeverity: .warning,
        summary: "A bundle adds or changes an entitlement compared with the baseline snapshot.",
    )

    package init() {}

    /// Reports one hit per added or changed entitlement key.
    package func check(_ context: RuleContext) -> [RuleHit] {
        guard let baseline = context.baseline else {
            return []
        }
        return context.contents.bundles.flatMap { bundle in
            let before = baseline.entitlements[bundle.path] ?? [:]
            return bundle.entitlements.keys.sorted().compactMap { key in
                Self.change(of: key, before: before[key], after: bundle.entitlements[key])
                    .map { RuleHit(path: bundle.displayPath, message: "\($0) compared with the baseline. Confirm the capability is intended; remove it from the entitlements file otherwise.") }
            }
        }
    }

    private static func change(of key: String, before: PlistValue?, after: PlistValue?) -> String? {
        guard let before else {
            return "adds entitlement \(key)"
        }
        return before == after ? nil : "changes entitlement \(key)"
    }
}
