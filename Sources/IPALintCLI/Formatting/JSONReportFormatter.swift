import Foundation
import IPALintKit

/// The whole report as one pretty-printed JSON document.
package struct JSONReportFormatter: ReportFormatting {
    package init() {}

    /// A single line holding the JSON document.
    package func lines(for report: LintReport) throws -> [String] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try [String(decoding: encoder.encode(report), as: UTF8.self)]
    }
}
