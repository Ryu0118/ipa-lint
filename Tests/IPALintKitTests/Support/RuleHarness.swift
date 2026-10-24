import Foundation
@testable import IPALintKit

/// Runs one rule against a synthetic app.
enum RuleHarness {
    static func check(
        _ rule: some LintRule,
        in app: TemporaryApp,
        entitlements: [String: [String: Any]] = [:],
        settings: RuleSettings = RuleSettings(),
        baseline: BundleSnapshot? = nil,
    ) async throws -> [RuleHit] {
        let contents = try await app.contents(entitlements: entitlements)
        let context = RuleContext(contents: contents, settings: settings, baseline: baseline, fileManager: FileManager.default)
        return rule.check(context)
    }
}
