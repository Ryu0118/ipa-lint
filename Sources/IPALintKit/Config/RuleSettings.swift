/// Per-rule settings from the `rules:` section of the configuration.
package struct RuleSettings: Decodable, Equatable, Sendable {
    /// Overrides the rule's default severity.
    package var severity: Severity?
    /// The size limit in bytes for rules that flag large files or growth.
    package var maxBytes: Int?
    /// The size in bytes below which a rule ignores a file.
    package var minBytes: Int?

    enum CodingKeys: String, CodingKey {
        case severity
        case maxBytes = "max_bytes"
        case minBytes = "min_bytes"
    }

    package init(severity: Severity? = nil, maxBytes: Int? = nil, minBytes: Int? = nil) {
        self.severity = severity
        self.maxBytes = maxBytes
        self.minBytes = minBytes
    }
}
