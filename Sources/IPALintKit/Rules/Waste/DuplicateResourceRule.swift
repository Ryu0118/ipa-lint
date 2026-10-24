import CryptoKit
import Foundation

/// Flags files whose content is identical to another file in the app.
package struct DuplicateResourceRule: LintRule {
    private static let defaultMinBytes = 10240
    private static let ignoredNames: Set<String> = ["Info.plist", "embedded.mobileprovision", "PkgInfo", "CodeResources"]
    private static let ignoredDirectories: Set<String> = ["_CodeSignature", "SC_Info"]

    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "duplicate-resource",
        category: .waste,
        defaultSeverity: .warning,
        summary: "Files with identical content are bundled more than once.",
    )

    package init() {}

    /// Reports one hit per group of identical files, at the first path of the group.
    package func check(_ context: RuleContext) -> [RuleHit] {
        let minBytes = context.settings.minBytes ?? Self.defaultMinBytes
        let candidates = context.contents.files.filter { $0.size >= minBytes && !Self.isIgnored($0.path) }
        let sizeGroups = Dictionary(grouping: candidates, by: \.size).filter { $0.value.count > 1 }
        var hits: [RuleHit] = []
        for (size, files) in sizeGroups {
            let byDigest = Dictionary(grouping: files.map(\.path)) { Self.digest(of: $0, in: context) }
            for (digest, paths) in byDigest where digest != nil && paths.count > 1 {
                hits.append(Self.hit(for: paths.sorted(), size: size))
            }
        }
        return hits.sorted { $0.path < $1.path }
    }

    private static func digest(of path: String, in context: RuleContext) -> String? {
        context.data(at: path).map { SHA256.hash(data: $0).map { String(format: "%02x", $0) }.joined() }
    }

    private static func hit(for sortedPaths: [String], size: Int) -> RuleHit {
        let copies = sortedPaths.dropFirst().joined(separator: ", ")
        let wasted = size * (sortedPaths.count - 1)
        return RuleHit(
            path: sortedPaths[0],
            message: "Identical content is bundled \(sortedPaths.count) times (also at \(copies)), wasting \(wasted) bytes; keep a single copy or allow it in .ipa-lint.yml with a reason.",
        )
    }

    private static func isIgnored(_ path: String) -> Bool {
        let components = path.split(separator: "/").map(String.init)
        guard let name = components.last else {
            return true
        }
        return ignoredNames.contains(name) || components.dropLast().contains { ignoredDirectories.contains($0) }
    }
}
