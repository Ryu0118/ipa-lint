import Foundation
@testable import IPALintKit
import Testing

struct LintRunnerTests {
    struct UnusedExtractor: ArchiveExtracting {
        func extract(archiveAt _: URL, into _: URL) async throws {}
    }

    @Test("applies the configured severity, disabled rules, and allow entries to rule hits")
    func appliesConfiguration() async throws {
        let app = try TemporaryApp()
        let config = app.root.appending(path: ".ipa-lint.yml")
        try Data("""
        disabled_rules: [off]
        rules:
          loud: { severity: warning }
        allow:
          - path: kept.json
            reason: needed at runtime
        """.utf8).write(to: config)
        let rules: [any LintRule] = [
            StubRule(id: "loud", hits: [RuleHit(path: "a.bin", message: "a")]),
            StubRule(id: "off", hits: [RuleHit(path: "b.bin", message: "b")]),
            StubRule(id: "kept", hits: [RuleHit(path: "kept.json", message: "k")]),
        ]
        let runner = LintRunner(
            fileManager: FileManager.default,
            extractor: UnusedExtractor(),
            entitlementsReader: StubEntitlementsReader(appURL: app.appURL, entitlements: [:]),
            rules: rules,
        )

        let report = try await runner.run(LintRequest(input: app.appURL, configuration: config, baseline: nil))

        #expect(report.findings == [Finding(ruleID: "loud", severity: .warning, path: "a.bin", message: "a")])
        #expect(report.suppressed.map(\.finding.ruleID) == ["kept"])
        #expect(!report.fails(strict: false))
        #expect(report.fails(strict: true))
    }
}
