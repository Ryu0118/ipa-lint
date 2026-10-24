import Foundation

/// Checks that a configuration only names known rules and that every allow entry has a reason.
package struct ConfigurationValidator: Sendable {
    private let knownRuleIDs: Set<String>

    package init(knownRuleIDs: Set<String>) {
        self.knownRuleIDs = knownRuleIDs
    }

    /// Throws the first problem found in `configuration`.
    package func validate(_ configuration: LintConfiguration) throws {
        let named = configuration.disabledRules + configuration.rules.keys.sorted() + configuration.allow.compactMap(\.rule)
        if let unknown = named.first(where: { !knownRuleIDs.contains($0) }) {
            throw ConfigurationError.unknownRule(unknown)
        }
        if let entry = configuration.allow.first(where: { $0.reason.trimmingCharacters(in: .whitespaces).isEmpty }) {
            throw ConfigurationError.missingReason(entry.path.pattern)
        }
    }
}
