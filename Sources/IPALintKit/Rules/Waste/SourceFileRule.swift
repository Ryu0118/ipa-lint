/// Flags source and tooling files that are never needed at runtime.
package struct SourceFileRule: LintRule {
    private static let extensions: Set<String> = [
        "swift", "m", "mm", "c", "cc", "cpp", "md", "markdown", "sh", "py", "rb",
        "yml", "yaml", "xcconfig", "orig", "rej", "log",
    ]
    private static let names: Set<String> = [
        ".DS_Store", "Podfile", "Podfile.lock", "Package.swift", "Package.resolved", "Cartfile", "Makefile",
    ]

    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "source-file",
        category: .waste,
        defaultSeverity: .error,
        summary: "Source code or tooling files (.swift, .md, Podfile, .DS_Store, ...) ship in the app.",
    )

    package init() {}

    /// Reports every source or tooling file, one hit per file.
    package func check(_ context: RuleContext) -> [RuleHit] {
        context.contents.files
            .map(\.path)
            .filter(Self.isSourceFile)
            .sorted()
            .map { RuleHit(path: $0, message: "Source or tooling file ships in the app; exclude it from the Release build or target membership, or allow it in .ipa-lint.yml with a reason.") }
    }

    private static func isSourceFile(_ path: String) -> Bool {
        let components = path.split(separator: "/").map(String.init)
        guard let name = components.last else {
            return false
        }
        if names.contains(name) {
            return true
        }
        let pathExtension = name.split(separator: ".", omittingEmptySubsequences: false).dropFirst().last.map { $0.lowercased() }
        if pathExtension == "h" {
            return !isFrameworkHeader(components)
        }
        return pathExtension.map(extensions.contains) == true
    }

    /// Headers under `<name>.framework/Headers` or `PrivateHeaders` belong to `framework-headers`.
    private static func isFrameworkHeader(_ components: [String]) -> Bool {
        let directories = components.dropLast()
        guard let frameworkIndex = directories.firstIndex(where: { $0.hasSuffix(".framework") }) else {
            return false
        }
        let next = directories.index(after: frameworkIndex)
        return next < directories.endIndex && ["Headers", "PrivateHeaders"].contains(directories[next])
    }
}
