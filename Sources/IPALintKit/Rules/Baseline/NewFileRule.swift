/// Flags files that are not in the baseline snapshot.
package struct NewFileRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "new-file",
        category: .baseline,
        defaultSeverity: .warning,
        summary: "A file is not in the baseline snapshot.",
    )

    package init() {}

    /// Reports each file whose path is absent from the baseline.
    package func check(_ context: RuleContext) -> [RuleHit] {
        guard let baseline = context.baseline else {
            return []
        }
        let known = Set(baseline.files.map(\.path))
        return context.contents.files
            .filter { !known.contains($0.path) }
            .map { RuleHit(path: $0.path, message: "New file (\(ByteSize.describe($0.size))) that is not in the baseline. Confirm it is meant to ship, or exclude it from the build.") }
    }
}
