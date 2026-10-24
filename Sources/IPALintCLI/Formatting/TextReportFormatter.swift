import IPALintKit

/// One line per finding, `severity: [rule] path: message`, then a summary.
package struct TextReportFormatter: ReportFormatting {
    package init() {}

    /// The finding lines followed by the summary line.
    package func lines(for report: LintReport) -> [String] {
        report.findings.map { "\($0.severity.rawValue): [\($0.ruleID)] \($0.path): \($0.message)" }
            + [ReportSummary.line(for: report)]
    }
}
