import FileManagerProtocol

/// Runs the enabled rules and turns their hits into findings with the configured severity.
package struct RuleEvaluator: Sendable {
    private let rules: [any LintRule]
    private let fileManager: any FileManagerProtocol

    package init(rules: [any LintRule], fileManager: some FileManagerProtocol) {
        self.rules = rules
        self.fileManager = fileManager
    }

    /// The findings of every rule not disabled by `configuration`.
    package func evaluate(_ contents: AppContents, configuration: LintConfiguration, baseline: BundleSnapshot?) -> [Finding] {
        rules.filter { !configuration.disabledRules.contains($0.descriptor.id) }.flatMap { rule in
            let descriptor = rule.descriptor
            let settings = configuration.settings(for: descriptor.id)
            let context = RuleContext(contents: contents, settings: settings, baseline: baseline, fileManager: fileManager)
            return rule.check(context).map { hit in
                Finding(
                    ruleID: descriptor.id,
                    severity: settings.severity ?? descriptor.defaultSeverity,
                    path: hit.path,
                    message: hit.message,
                )
            }
        }
    }
}
