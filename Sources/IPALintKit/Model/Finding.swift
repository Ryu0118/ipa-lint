/// A rule hit with the severity the configuration resolved for it.
package struct Finding: Codable, Equatable, Sendable {
    /// The identifier of the rule that produced the finding.
    package var ruleID: String
    /// How serious the finding is.
    package var severity: Severity
    /// The path inside the app, relative to the `.app` directory.
    package var path: String
    /// What is wrong and how to fix it.
    package var message: String

    package init(ruleID: String, severity: Severity, path: String, message: String) {
        self.ruleID = ruleID
        self.severity = severity
        self.path = path
        self.message = message
    }
}
