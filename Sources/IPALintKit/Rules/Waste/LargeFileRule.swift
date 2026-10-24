/// Flags large non-binary files, which are candidates for on-demand resources or compression.
package struct LargeFileRule: LintRule {
    private static let defaultMaxBytes = 2_097_152

    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "large-file",
        category: .waste,
        defaultSeverity: .warning,
        summary: "A resource file (not a Mach-O binary, Assets.car, or the code signature) is larger than the size limit.",
    )

    package init() {}

    /// Reports every file larger than `max_bytes` that is not a Mach-O binary, `Assets.car`, or code-signature data.
    package func check(_ context: RuleContext) -> [RuleHit] {
        let limit = context.settings.maxBytes ?? Self.defaultMaxBytes
        return context.contents.files
            .filter { $0.size > limit && Self.isResource($0.path, in: context) }
            .sorted { $0.path < $1.path }
            .map { file in
                RuleHit(
                    path: file.path,
                    message: "File is \(ByteSize.megabytes(file.size)), above the \(ByteSize.megabytes(limit)) limit; move it to on-demand resources, compress it, or keep it out of the bundle, or allow it in .ipa-lint.yml with a reason.",
                )
            }
    }

    private static func isResource(_ path: String, in context: RuleContext) -> Bool {
        let components = path.split(separator: "/")
        guard components.last != "Assets.car", !components.contains("_CodeSignature"), let data = context.data(at: path) else {
            return false
        }
        return !MachOMagic.isMachO(data)
    }
}
