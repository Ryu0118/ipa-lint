import Foundation
@testable import IPALintCLI
import IPALintKit
import Testing

struct ReportFormatterTests {
    let report = LintReport(
        findings: [
            Finding(ruleID: "dev-artifact", severity: .error, path: "mock.json", message: "Remove it."),
            Finding(ruleID: "large-file", severity: .warning, path: "big.bin", message: "100%\nlarge"),
        ],
        suppressed: [SuppressedFinding(finding: Finding(ruleID: "dev-artifact", severity: .error, path: "a.bin", message: "m"), reason: "r")],
    )

    @Test("text output prints one line per finding and a pluralized summary")
    func text() {
        #expect(TextReportFormatter().lines(for: report) == [
            "error: [dev-artifact] mock.json: Remove it.",
            "warning: [large-file] big.bin: 100%\nlarge",
            "1 error, 1 warning, 1 suppressed",
        ])
    }

    @Test("GitHub output emits workflow commands and escapes %, CR, and LF in the message")
    func github() {
        let lines = GitHubReportFormatter().lines(for: report)
        #expect(lines[0] == "::error title=ipa-lint dev-artifact::mock.json: Remove it.")
        #expect(lines[1] == "::warning title=ipa-lint large-file::big.bin: 100%25%0Alarge")
    }

    @Test("JSON output round-trips to the same report")
    func json() throws {
        let line = try #require(try JSONReportFormatter().lines(for: report).first)
        #expect(try JSONDecoder().decode(LintReport.self, from: Data(line.utf8)) == report)
    }
}
