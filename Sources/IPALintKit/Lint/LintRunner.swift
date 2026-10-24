import FileManagerProtocol
import Foundation

/// Lints an app: loads the configuration and baseline, runs the rules, and applies the `allow` entries.
package struct LintRunner: Sendable {
    private let fileManager: any FileManagerProtocol
    private let reader: AppReader
    private let rules: [any LintRule]

    package init(
        fileManager: some FileManagerProtocol,
        extractor: some ArchiveExtracting,
        entitlementsReader: some EntitlementsReading,
        rules: [any LintRule] = RuleCatalog.all,
    ) {
        self.fileManager = fileManager
        reader = AppReader(fileManager: fileManager, extractor: extractor, entitlementsReader: entitlementsReader)
        self.rules = rules
    }

    /// Runs the lint described by `request`.
    package func run(_ request: LintRequest) async throws -> LintReport {
        let configuration = try request.configuration.map(ConfigurationLoader(fileManager: fileManager).load) ?? .empty
        let knownIDs = Set(rules.map(\.descriptor.id) + [RuleCatalog.staleAllow.id])
        try ConfigurationValidator(knownRuleIDs: knownIDs).validate(configuration)
        let baseline = try request.baseline.map(SnapshotLoader(fileManager: fileManager).load)
        let evaluator = RuleEvaluator(rules: rules, fileManager: fileManager)
        let findings = try await reader.withContents(of: request.input) { contents in
            evaluator.evaluate(contents, configuration: configuration, baseline: baseline)
        }
        return SuppressionApplier(configuration: configuration).apply(to: findings)
    }
}
