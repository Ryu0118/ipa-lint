import ArgumentParser

/// The `--format` values.
package enum ReportFormat: String, CaseIterable, ExpressibleByArgument, Sendable {
    case text
    case json
    case github

    /// The formatter for this format.
    package var formatter: any ReportFormatting {
        switch self {
        case .text: TextReportFormatter()
        case .json: JSONReportFormatter()
        case .github: GitHubReportFormatter()
        }
    }
}
