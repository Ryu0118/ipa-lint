/// One architecture of a Mach-O file: its CPU type and the platforms its build-version load commands name.
package struct MachOSlice: Equatable, Sendable {
    /// The `cputype` field of the Mach-O header.
    package var cpuType: UInt32
    /// The `platform` of every `LC_BUILD_VERSION` command, in file order.
    package var platforms: [UInt32]

    package init(cpuType: UInt32, platforms: [UInt32]) {
        self.cpuType = cpuType
        self.platforms = platforms
    }
}
