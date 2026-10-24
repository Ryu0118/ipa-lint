/// The result of a lint run.
package struct LintReport: Codable, Equatable, Sendable {
    /// Findings that count, sorted by severity (errors first), rule, and path.
    package var findings: [Finding]
    /// Findings an `allow` entry suppressed.
    package var suppressed: [SuppressedFinding]

    package init(findings: [Finding], suppressed: [SuppressedFinding]) {
        self.findings = findings
        self.suppressed = suppressed
    }

    /// Whether the run fails: any error, or any finding at all in strict mode.
    package func fails(strict: Bool) -> Bool {
        findings.contains { strict || $0.severity == .error }
    }

    /// The number of findings with `severity`.
    package func count(of severity: Severity) -> Int {
        findings.count { $0.severity == severity }
    }
}
