/// Every rule this tool ships, in the order they run and are listed.
package enum RuleCatalog {
    /// Reported when an `allow` entry suppresses nothing, so stale exceptions get removed.
    package static let staleAllow = RuleDescriptor(
        id: "stale-allow",
        category: .review,
        defaultSeverity: .warning,
        summary: "An allow entry in the configuration matches no finding; remove it.",
    )

    /// The rules that inspect the app.
    package static let all: [any LintRule] = []

    /// The descriptors of every rule, including `stale-allow`.
    package static var descriptors: [RuleDescriptor] {
        all.map(\.descriptor) + [staleAllow]
    }
}
