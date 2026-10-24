import Foundation
@testable import IPALintKit
import Testing

struct LargeFileRuleTests {
    @Test("flags files strictly larger than the default 2 MiB limit")
    func appliesDefaultLimit() async throws {
        let app = try TemporaryApp()
        try app.write("at-limit.bin", size: 2_097_152)
        try app.write("over-limit.bin", size: 2_097_153)

        let hits = try await RuleHarness.check(LargeFileRule(), in: app)

        #expect(hits.map(\.path) == ["over-limit.bin"])
    }

    @Test("honours max_bytes and states size and limit in MB")
    func honoursMaxBytes() async throws {
        let app = try TemporaryApp()
        try app.write("big.bin", size: 3_145_728)

        let hits = try await RuleHarness.check(LargeFileRule(), in: app, settings: RuleSettings(maxBytes: 1_048_576))
        let none = try await RuleHarness.check(LargeFileRule(), in: app, settings: RuleSettings(maxBytes: 3_145_728))

        #expect(hits.count == 1)
        #expect(hits[0].message.contains("3.0 MB"))
        #expect(hits[0].message.contains("1.0 MB"))
        #expect(none.isEmpty)
    }

    @Test("skips Mach-O binaries, Assets.car, and the code signature")
    func skipsBinariesAndAssetCatalogs() async throws {
        let app = try TemporaryApp()
        var macho = Data([0xCF, 0xFA, 0xED, 0xFE])
        macho.append(Data(count: 3_000_000))
        try app.write("Frameworks/A.framework/A", data: macho)
        try app.write("Assets.car", size: 3_000_000)
        try app.write("Sub/Assets.car", size: 3_000_000)
        try app.write("_CodeSignature/CodeResources", size: 3_000_000)
        try app.write("PlugIns/W.appex/_CodeSignature/CodeResources", size: 3_000_000)
        try app.write("video.mp4", size: 3_000_000)

        let hits = try await RuleHarness.check(LargeFileRule(), in: app)

        #expect(hits.map(\.path) == ["video.mp4"])
    }

    @Test("defaults to warning severity in the waste category")
    func descriptor() {
        let descriptor = LargeFileRule().descriptor

        #expect(descriptor.id == "large-file")
        #expect(descriptor.category == .waste)
        #expect(descriptor.defaultSeverity == .warning)
    }
}
