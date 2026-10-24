import Foundation

/// Flags app extensions whose minimum OS version differs from the app's.
package struct MinOSMismatchRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "min-os-mismatch",
        category: .review,
        defaultSeverity: .warning,
        summary: "An app extension's MinimumOSVersion differs from the app's.",
    )

    private static let extensionDirectories: Set<String> = ["PlugIns", "Extensions"]

    package init() {}

    /// Compares each top-level extension's `MinimumOSVersion` with the app's.
    package func check(_ context: RuleContext) -> [RuleHit] {
        guard let host = Self.version(of: context.contents.bundles.first { $0.path.isEmpty }) else {
            return []
        }
        return context.contents.bundles.compactMap { bundle in
            guard Self.isTopLevelExtension(bundle),
                  let version = Self.version(of: bundle),
                  let order = Self.compare(version.components, host.components),
                  order != .orderedSame
            else {
                return nil
            }
            return RuleHit(path: bundle.path, message: Self.message(extensionVersion: version.text, hostVersion: host.text, order: order))
        }
    }

    private static func isTopLevelExtension(_ bundle: EmbeddedBundle) -> Bool {
        let parts = bundle.path.split(separator: "/")
        return bundle.kind == .appExtension && parts.count == 2 && extensionDirectories.contains(String(parts[0]))
    }

    /// The version string and its numeric components; nil when it is missing or has a non-numeric part.
    private static func version(of bundle: EmbeddedBundle?) -> (text: String, components: [Int])? {
        guard let text = bundle?.infoPlist["MinimumOSVersion"]?.stringValue else {
            return nil
        }
        let parts = text.split(separator: ".", omittingEmptySubsequences: false)
        let components = parts.compactMap { Int($0) }
        guard components.count == parts.count else {
            return nil
        }
        return (text, components)
    }

    /// Orders two dotted versions numerically, treating missing trailing components as zero.
    private static func compare(_ lhs: [Int], _ rhs: [Int]) -> ComparisonResult? {
        for index in 0 ..< max(lhs.count, rhs.count) {
            let left = index < lhs.count ? lhs[index] : 0
            let right = index < rhs.count ? rhs[index] : 0
            if left != right {
                return left < right ? .orderedAscending : .orderedDescending
            }
        }
        return .orderedSame
    }

    private static func message(extensionVersion: String, hostVersion: String, order: ComparisonResult) -> String {
        if order == .orderedDescending {
            return "MinimumOSVersion \(extensionVersion) is higher than the app's \(hostVersion), so the extension will not load on OS versions between the two. Lower the extension's deployment target to \(hostVersion)."
        }
        return "MinimumOSVersion \(extensionVersion) is lower than the app's \(hostVersion) and inconsistent with it. Set the extension's deployment target to \(hostVersion)."
    }
}
