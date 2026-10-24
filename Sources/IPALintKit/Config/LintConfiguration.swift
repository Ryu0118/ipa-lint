/// The contents of an `.ipa-lint.yml` file.
package struct LintConfiguration: Decodable, Equatable, Sendable {
    /// The configuration used when no file is given.
    package static let empty = LintConfiguration()

    /// Rules that do not run.
    package var disabledRules: [String]
    /// Per-rule settings keyed by rule identifier.
    package var rules: [String: RuleSettings]
    /// Findings to suppress, each with a reason.
    package var allow: [AllowEntry]

    enum CodingKeys: String, CodingKey {
        case disabledRules = "disabled_rules"
        case rules
        case allow
    }

    package init(disabledRules: [String] = [], rules: [String: RuleSettings] = [:], allow: [AllowEntry] = []) {
        self.disabledRules = disabledRules
        self.rules = rules
        self.allow = allow
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        disabledRules = try container.decodeIfPresent([String].self, forKey: .disabledRules) ?? []
        rules = try container.decodeIfPresent([String: RuleSettings].self, forKey: .rules) ?? [:]
        allow = try container.decodeIfPresent([AllowEntry].self, forKey: .allow) ?? []
    }

    /// The settings for `ruleID`, or defaults when the configuration has none.
    package func settings(for ruleID: String) -> RuleSettings {
        rules[ruleID] ?? RuleSettings()
    }
}
