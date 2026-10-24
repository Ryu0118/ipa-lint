import Foundation
@testable import IPALintKit
import Testing

struct SimulatorSliceRuleTests {
    @Test("accepts a device-only binary")
    func acceptsDeviceBinary() async throws {
        let app = try TemporaryApp()
        try app.write("Sample", data: MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [2]))

        let hits = try await RuleHarness.check(SimulatorSliceRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("flags a simulator platform in the build version", arguments: [(7, "iOS Simulator"), (8, "tvOS Simulator"), (9, "watchOS Simulator"), (12, "visionOS Simulator")] as [(UInt32, String)])
    func flagsSimulatorPlatform(platform: UInt32, name: String) async throws {
        let app = try TemporaryApp()
        try app.write("Kit", data: MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [platform]))

        let hits = try await RuleHarness.check(SimulatorSliceRule(), in: app)

        #expect(hits.map(\.path) == ["Kit"])
        #expect(hits.first?.message.contains(name) == true)
    }

    @Test("does not treat device platforms next to the simulator numbers as simulators", arguments: [1, 2, 3, 4, 5, 6, 10, 11] as [UInt32])
    func ignoresDevicePlatforms(platform: UInt32) async throws {
        let app = try TemporaryApp()
        try app.write("Kit", data: MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [platform]))

        let hits = try await RuleHarness.check(SimulatorSliceRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("flags x86_64 and i386 slices by name", arguments: [(MachOFixture.x86_64, "x86_64"), (MachOFixture.i386, "i386")])
    func flagsIntelSlices(cpuType: UInt32, name: String) async throws {
        let app = try TemporaryApp()
        try app.write("Kit", data: MachOFixture.thin(cpuType: cpuType, is64: cpuType != MachOFixture.i386))

        let hits = try await RuleHarness.check(SimulatorSliceRule(), in: app)

        #expect(hits.map(\.path) == ["Kit"])
        #expect(hits.first?.message.contains(name) == true)
    }

    @Test("reports one hit for a universal file with several offending slices")
    func oneHitPerFile() async throws {
        let app = try TemporaryApp()
        try app.write("Frameworks/Kit.framework/Kit", data: MachOFixture.fat([
            MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [2]),
            MachOFixture.thin(cpuType: MachOFixture.arm64, platforms: [7]),
            MachOFixture.thin(cpuType: MachOFixture.x86_64, platforms: [7]),
        ]))

        let hits = try await RuleHarness.check(SimulatorSliceRule(), in: app)

        #expect(hits.count == 1)
        #expect(hits.first?.path == "Frameworks/Kit.framework/Kit")
        #expect(hits.first?.message.contains("x86_64") == true)
        #expect(hits.first?.message.contains("iOS Simulator") == true)
    }

    @Test("ignores files that are not Mach-O and reports hits in path order")
    func ignoresOtherFilesAndSorts() async throws {
        let app = try TemporaryApp()
        try app.write("b", data: MachOFixture.thin(cpuType: MachOFixture.x86_64))
        try app.write("a", data: MachOFixture.thin(cpuType: MachOFixture.x86_64))
        try app.write("notes.txt", text: "x86_64 iOS Simulator")

        let hits = try await RuleHarness.check(SimulatorSliceRule(), in: app)

        #expect(hits.map(\.path) == ["a", "b"])
    }
}
