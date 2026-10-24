import IPALintKit

/// GitHub Actions workflow commands (`::error` / `::warning`), so findings show up as annotations.
package struct GitHubReportFormatter: ReportFormatting {
    package init() {}

    /// One workflow command per finding, then the summary line.
    package func lines(for report: LintReport) -> [String] {
        report.findings.map { finding in
            "::\(finding.severity.rawValue) title=ipa-lint \(finding.ruleID)::\(Self.escape("\(finding.path): \(finding.message)"))"
        } + [ReportSummary.line(for: report)]
    }

    /// Escapes the characters GitHub treats specially in a workflow command message.
    static func escape(_ message: String) -> String {
        message
            .replacingOccurrences(of: "%", with: "%25")
            .replacingOccurrences(of: "\r", with: "%0D")
            .replacingOccurrences(of: "\n", with: "%0A")
    }
}
