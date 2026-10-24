/// Flags build-time interface files (headers, modules) inside embedded frameworks.
package struct FrameworkHeadersRule: LintRule {
    private static let directories: Set<String> = ["Headers", "PrivateHeaders", "Modules"]

    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "framework-headers",
        category: .waste,
        defaultSeverity: .warning,
        summary: "Headers, private headers, or modules of an embedded framework ship in the app.",
    )

    package init() {}

    /// Reports one hit per framework directory (`Headers`, `PrivateHeaders`, `Modules`) with its file count and size.
    package func check(_ context: RuleContext) -> [RuleHit] {
        var totals: [String: (count: Int, bytes: Int)] = [:]
        for file in context.contents.files {
            guard let directory = Self.interfaceDirectory(of: file.path) else {
                continue
            }
            let current = totals[directory, default: (0, 0)]
            totals[directory] = (current.count + 1, current.bytes + file.size)
        }
        return totals.keys.sorted().map { directory in
            let total = totals[directory, default: (0, 0)]
            let noun = total.count == 1 ? "file" : "files"
            return RuleHit(
                path: directory,
                message: "\(total.count) \(noun) (\(ByteSize.describe(total.bytes))) of build-time headers ship in the app; strip them in a build phase before archiving, or allow it in .ipa-lint.yml with a reason.",
            )
        }
    }

    /// The `<x>.framework/<Headers|PrivateHeaders|Modules>` directory that contains `path`, if any.
    private static func interfaceDirectory(of path: String) -> String? {
        let components = path.split(separator: "/").map(String.init)
        // The file itself must sit below the interface directory, so the directory is never the last component.
        let candidates = components.indices.dropLast().dropFirst()
        guard let index = candidates.first(where: {
            directories.contains(components[$0]) && components[$0 - 1].hasSuffix(".framework")
        }) else {
            return nil
        }
        return components[...index].joined(separator: "/")
    }
}
