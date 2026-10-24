/// A check over the contents of an app.
package protocol LintRule: Sendable {
    /// The rule's identity and defaults.
    var descriptor: RuleDescriptor { get }

    /// Returns every problem the rule finds in `context`.
    func check(_ context: RuleContext) -> [RuleHit]
}
