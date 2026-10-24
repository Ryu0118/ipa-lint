import IPALintKit

/// Renders a lint report as output lines.
package protocol ReportFormatting: Sendable {
    /// The lines to write to standard output for `report`.
    func lines(for report: LintReport) throws -> [String]
}
