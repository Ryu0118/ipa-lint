/// Flags Mach-O files that contain slices built for the simulator or for Intel CPUs.
package struct SimulatorSliceRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "simulator-slice",
        category: .review,
        defaultSeverity: .error,
        summary: "A binary contains an x86_64 or i386 slice or a simulator platform; App Store Connect rejects it.",
    )

    private static let intelCPUs: [UInt32: String] = [0x0100_0007: "x86_64", 7: "i386"]
    private static let simulatorPlatforms: [UInt32: String] = [7: "iOS Simulator", 8: "tvOS Simulator", 9: "watchOS Simulator", 12: "visionOS Simulator"]

    package init() {}

    /// Reports one hit per Mach-O file, naming the offending architectures and platforms.
    package func check(_ context: RuleContext) -> [RuleHit] {
        context.contents.files.compactMap { file in
            guard let data = context.data(at: file.path), MachOMagic.isMachO(data) else {
                return nil
            }
            let offenders = Self.offenders(in: MachOSlices.read(data))
            guard !offenders.isEmpty else {
                return nil
            }
            return RuleHit(
                path: file.path,
                message: "Contains \(offenders.joined(separator: ", ")). App Store Connect rejects simulator slices; embed the device slice of the XCFramework, or strip the slice with `lipo -remove`.",
            )
        }
    }

    /// The architecture and platform names, each listed once in first-seen order.
    private static func offenders(in slices: [MachOSlice]) -> [String] {
        let names = slices.flatMap { slice in
            [intelCPUs[slice.cpuType]].compactMap(\.self) + slice.platforms.compactMap { simulatorPlatforms[$0] }
        }
        var seen: Set<String> = []
        return names.filter { seen.insert($0).inserted }
    }
}
