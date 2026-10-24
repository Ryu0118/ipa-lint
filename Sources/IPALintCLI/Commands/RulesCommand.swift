import ArgumentParser
import IPALintKit

/// `ipa-lint rules`: lists every rule with its category, default severity, and summary.
package struct RulesCommand: ContextualCommand {
    /// Command name and help text.
    package static let configuration = CommandConfiguration(
        commandName: "rules",
        abstract: "List the rules.",
    )

    package init() {}

    /// Writes one line per rule.
    package func run(context: CLIContext) async throws {
        let width = RuleCatalog.descriptors.map(\.id.count).max() ?? 0
        for rule in RuleCatalog.descriptors {
            let id = rule.id.padding(toLength: width, withPad: " ", startingAt: 0)
            let category = rule.category.rawValue.padding(toLength: 8, withPad: " ", startingAt: 0)
            let severity = rule.defaultSeverity.rawValue.padding(toLength: 7, withPad: " ", startingAt: 0)
            context.output.standardOutput("\(id)  \(category)  \(severity)  \(rule.summary)")
        }
    }
}
