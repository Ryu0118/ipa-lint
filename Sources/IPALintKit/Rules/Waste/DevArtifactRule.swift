/// Flags test and development data that ships in the app.
package struct DevArtifactRule: LintRule {
    private static let extensions: Set<String> = ["xctestplan", "xcresult"]
    private static let directories: Set<String> = ["TestData", "Fixtures", "__Snapshots__", "Preview Content"]

    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "dev-artifact",
        category: .waste,
        defaultSeverity: .error,
        summary: "Test or development data (test plans, mocks, fixtures, snapshots) ships in the app.",
    )

    package init() {}

    /// Reports every file that looks like test or development data, one hit per file.
    package func check(_ context: RuleContext) -> [RuleHit] {
        context.contents.files
            .map(\.path)
            .filter(Self.isDevArtifact)
            .sorted()
            .map { RuleHit(path: $0, message: "Development artifact ships in the app; exclude it from the Release build or target membership, or allow it in .ipa-lint.yml with a reason.") }
    }

    private static func isDevArtifact(_ path: String) -> Bool {
        let components = path.split(separator: "/").map(String.init)
        guard let name = components.last else {
            return false
        }
        let pathExtension = name.split(separator: ".", omittingEmptySubsequences: false).dropFirst().last.map { $0.lowercased() }
        return pathExtension.map(extensions.contains) == true
            || name.hasPrefix("mock-")
            || name.hasPrefix("Mock")
            || components.contains { directories.contains($0) || $0.hasSuffix(".xcresult") }
    }
}
