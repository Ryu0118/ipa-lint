@testable import IPALintKit

/// A rule that reports fixed hits, for runner and suppression tests.
struct StubRule: LintRule {
    let descriptor: RuleDescriptor
    let hits: [RuleHit]

    init(id: String, severity: Severity = .error, hits: [RuleHit]) {
        descriptor = RuleDescriptor(id: id, category: .waste, defaultSeverity: severity, summary: "Stub rule \(id).")
        self.hits = hits
    }

    func check(_: RuleContext) -> [RuleHit] {
        hits
    }
}
