import Foundation
@testable import IPALintKit
import Testing

struct ConfigurationTests {
    let validator = ConfigurationValidator(knownRuleIDs: ["dev-artifact", "large-file"])

    @Test("decodes disabled rules, rule settings, and allow entries from YAML")
    func decodesYAML() throws {
        let app = try TemporaryApp()
        let file = app.root.appending(path: ".ipa-lint.yml")
        try Data("""
        disabled_rules: [large-file]
        rules:
          dev-artifact:
            severity: warning
            max_bytes: 10
        allow:
          - rule: dev-artifact
            path: "mock-*.json"
            reason: UI tests read it
        """.utf8).write(to: file)

        let configuration = try ConfigurationLoader(fileManager: FileManager.default).load(file)

        #expect(configuration.disabledRules == ["large-file"])
        #expect(configuration.settings(for: "dev-artifact") == RuleSettings(severity: .warning, maxBytes: 10))
        #expect(configuration.allow == [AllowEntry(rule: "dev-artifact", path: PathPattern("mock-*.json"), reason: "UI tests read it")])
    }

    @Test("rejects a rule identifier that does not exist")
    func rejectsUnknownRule() {
        #expect(throws: ConfigurationError.unknownRule("typo")) {
            try validator.validate(LintConfiguration(disabledRules: ["typo"]))
        }
    }

    @Test("rejects an allow entry without a reason")
    func rejectsMissingReason() {
        let entry = AllowEntry(rule: nil, path: PathPattern("a.bin"), reason: "  ")
        #expect(throws: ConfigurationError.missingReason("a.bin")) {
            try validator.validate(LintConfiguration(allow: [entry]))
        }
    }
}
