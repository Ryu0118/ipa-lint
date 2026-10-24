import IPALintKit

/// The closing count line shared by the text and GitHub formats.
package enum ReportSummary {
    /// For example `2 errors, 1 warning, 3 suppressed`.
    package static func line(for report: LintReport) -> String {
        let errors = report.count(of: .error)
        let warnings = report.count(of: .warning)
        return "\(plural(errors, "error")), \(plural(warnings, "warning")), \(report.suppressed.count) suppressed"
    }

    private static func plural(_ count: Int, _ noun: String) -> String {
        "\(count) \(noun)\(count == 1 ? "" : "s")"
    }
}
