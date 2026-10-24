import Foundation
@testable import IPALintKit
import Testing

struct MachOSlicesTests {
    @Test("reads the cpu type and every LC_BUILD_VERSION platform of a thin 64-bit file, walking past other commands")
    func readsThin64() {
        let data = MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [2, 6])

        #expect(MachOSlices.read(data) == [MachOSlice(cpuType: MachOFixture.arm64, platforms: [2, 6])])
    }

    @Test("reads a thin 32-bit file whose header is 28 bytes")
    func readsThin32() {
        let data = MachOFixture.thin(cpuType: MachOFixture.i386, platforms: [7], is64: false)

        #expect(MachOSlices.read(data) == [MachOSlice(cpuType: MachOFixture.i386, platforms: [7])])
    }

    @Test("reads every slice of a universal file in both the 32-bit and 64-bit fat layouts", arguments: [false, true])
    func readsFat(wide: Bool) {
        let data = MachOFixture.fat(
            [
                MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [2]),
                MachOFixture.thin(cpuType: MachOFixture.x86_64, platforms: [7]),
            ],
            wide: wide,
        )

        #expect(MachOSlices.read(data) == [
            MachOSlice(cpuType: MachOFixture.arm64, platforms: [2]),
            MachOSlice(cpuType: MachOFixture.x86_64, platforms: [7]),
        ])
    }

    @Test("returns no slices for malformed or truncated data instead of crashing", arguments: MachOSlicesTests.malformed)
    func rejectsMalformed(data: Data) {
        #expect(MachOSlices.read(data).isEmpty)
    }

    @Test("skips a fat slice that points past the end of the file but keeps the valid ones")
    func skipsOutOfRangeFatSlice() {
        var data = MachOFixture.fat([
            MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [2]),
            MachOFixture.thin(cpuType: MachOFixture.x86_64, platforms: [7]),
        ])
        data.removeLast(10)

        #expect(MachOSlices.read(data) == [MachOSlice(cpuType: MachOFixture.arm64, platforms: [2])])
    }

    private static var malformed: [Data] {
        let thin = MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [2])
        var zeroSizedCommand = thin
        zeroSizedCommand.replaceSubrange(36 ..< 40, with: [0, 0, 0, 0])
        var hugeFatCount = MachOFixture.fat([thin])
        hugeFatCount.replaceSubrange(4 ..< 8, with: [0xFF, 0xFF, 0xFF, 0xFF])
        return [
            Data(),
            Data([0xCF, 0xFA, 0xED]),
            Data(thin.prefix(20)),
            Data(thin.dropLast(4)),
            zeroSizedCommand,
            hugeFatCount,
            Data(MachOFixture.fat([thin]).prefix(12)),
            Data(repeating: 0x41, count: 64),
        ]
    }
}
