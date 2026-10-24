/// Flags entitlements that carry development values, which means the build was not signed for distribution.
package struct DebugEntitlementRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "debug-entitlement",
        category: .security,
        defaultSeverity: .error,
        summary: "An entitlement has a development value (get-task-allow, development push, iCloud, or App Attest environment).",
    )

    private static let debugValues: [(key: String, value: PlistValue)] = [
        ("get-task-allow", .bool(true)),
        ("aps-environment", .string("development")),
        ("com.apple.developer.icloud-container-environment", .string("Development")),
        ("com.apple.developer.devicecheck.appattest-environment", .string("development")),
    ]

    package init() {}

    /// Returns one hit per development entitlement in each bundle.
    package func check(_ context: RuleContext) -> [RuleHit] {
        context.contents.bundles.flatMap { bundle in
            Self.debugValues.filter { bundle.entitlements[$0.key] == $0.value }.map { entry in
                RuleHit(
                    path: bundle.displayPath,
                    message: "Entitlement \(entry.key) is \(Self.describe(entry.value)); a distribution build must use the production value, so archive with a distribution or App Store profile.",
                )
            }
        }
    }

    private static func describe(_ value: PlistValue) -> String {
        switch value {
        case let .bool(flag): "\(flag)"
        case let .string(text): "\"\(text)\""
        default: "set"
        }
    }
}
