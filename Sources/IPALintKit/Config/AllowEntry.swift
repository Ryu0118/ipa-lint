/// An `allow:` entry: keeps findings for matching paths out of the result, with a reason.
package struct AllowEntry: Decodable, Equatable, Sendable {
    /// The rule to suppress; nil suppresses every rule for the path.
    package var rule: String?
    /// The path pattern the entry applies to (see `PathPattern`).
    package var path: PathPattern
    /// Why the file is allowed. Required so every exception documents itself.
    package var reason: String

    package init(rule: String?, path: PathPattern, reason: String) {
        self.rule = rule
        self.path = path
        self.reason = reason
    }

    /// Whether this entry suppresses `finding`.
    package func suppresses(_ finding: Finding) -> Bool {
        (rule == nil || rule == finding.ruleID) && path.matches(finding.path)
    }
}
