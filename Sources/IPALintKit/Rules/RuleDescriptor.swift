/// The identity and defaults of a rule, shown by `ipa-lint rules`.
package struct RuleDescriptor: Equatable, Sendable {
    /// The identifier used in the configuration and in findings.
    package var id: String
    /// The group the rule belongs to.
    package var category: RuleCategory
    /// The severity used when the configuration does not override it.
    package var defaultSeverity: Severity
    /// One sentence on what the rule flags.
    package var summary: String

    package init(id: String, category: RuleCategory, defaultSeverity: Severity, summary: String) {
        self.id = id
        self.category = category
        self.defaultSeverity = defaultSeverity
        self.summary = summary
    }
}
