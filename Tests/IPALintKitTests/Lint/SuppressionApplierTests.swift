@testable import IPALintKit
import Testing

struct SuppressionApplierTests {
    let mock = Finding(ruleID: "dev-artifact", severity: .error, path: "mock.json", message: "m")
    let header = Finding(ruleID: "framework-headers", severity: .warning, path: "Frameworks/A.framework/Headers/A.h", message: "h")

    @Test("an entry scoped to a rule suppresses only that rule's findings and records the reason")
    func scopedEntry() {
        let entry = AllowEntry(rule: "dev-artifact", path: PathPattern("*.json"), reason: "UI test data")
        let report = SuppressionApplier(configuration: LintConfiguration(allow: [entry])).apply(to: [mock, header])

        #expect(report.findings == [header])
        #expect(report.suppressed == [SuppressedFinding(finding: mock, reason: "UI test data")])
    }

    @Test("an entry that matches nothing becomes a stale-allow warning")
    func staleEntry() {
        let entry = AllowEntry(rule: "dev-artifact", path: PathPattern("gone.bin"), reason: "old")
        let report = SuppressionApplier(configuration: LintConfiguration(allow: [entry])).apply(to: [mock])

        #expect(report.findings.map(\.ruleID) == ["dev-artifact", "stale-allow"])
        #expect(report.findings.last?.severity == .warning)
    }

    @Test("errors sort before warnings")
    func sortsBySeverity() {
        let report = SuppressionApplier(configuration: .empty).apply(to: [header, mock])

        #expect(report.findings == [mock, header])
    }
}
