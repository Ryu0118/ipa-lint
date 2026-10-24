import Foundation

/// Flags growth of the whole app, or of single files, beyond a threshold compared with the baseline snapshot.
package struct SizeGrowthRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "size-growth",
        category: .baseline,
        defaultSeverity: .warning,
        summary: "The app or a file grew by more than max_bytes compared with the baseline snapshot.",
    )

    private static let defaultMaxBytes = 1_048_576

    package init() {}

    /// Reports total growth at `.` and each file that grew by more than the threshold.
    package func check(_ context: RuleContext) -> [RuleHit] {
        guard let baseline = context.baseline else {
            return []
        }
        let threshold = context.settings.maxBytes ?? Self.defaultMaxBytes
        let before = baseline.totalSize
        let after = context.contents.files.reduce(0) { $0 + $1.size }
        var hits: [RuleHit] = []
        if after - before > threshold {
            hits.append(RuleHit(
                path: ".",
                message: "The app grew from \(ByteSize.megabytes(before)) to \(ByteSize.megabytes(after)) (+\(ByteSize.megabytes(after - before))), more than the allowed \(ByteSize.megabytes(threshold)). Check the files that grew or were added.",
            ))
        }
        let previous = Dictionary(baseline.files.map { ($0.path, $0.size) }, uniquingKeysWith: { first, _ in first })
        let grown = context.contents.files.compactMap { file -> RuleHit? in
            guard let old = previous[file.path], file.size - old > threshold else {
                return nil
            }
            return RuleHit(path: file.path, message: "Grew from \(ByteSize.megabytes(old)) to \(ByteSize.megabytes(file.size)) (+\(ByteSize.megabytes(file.size - old))), more than the allowed \(ByteSize.megabytes(threshold)). Check whether the growth is intended.")
        }
        return hits + grown
    }
}
