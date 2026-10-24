import Foundation
@testable import IPALintKit
import Testing

struct DuplicateResourceRuleTests {
    @Test("groups identical files and reports the first path with the wasted bytes")
    func reportsDuplicateGroup() async throws {
        let app = try TemporaryApp()
        let payload = Data(repeating: 7, count: 20000)
        try app.write("b/copy.bin", data: payload)
        try app.write("a/orig.bin", data: payload)
        try app.write("c/copy2.bin", data: payload)

        let hits = try await RuleHarness.check(DuplicateResourceRule(), in: app)

        #expect(hits.map(\.path) == ["a/orig.bin"])
        #expect(hits[0].message.contains("b/copy.bin"))
        #expect(hits[0].message.contains("c/copy2.bin"))
        #expect(hits[0].message.contains("40000 bytes"))
    }

    @Test("does not flag same-size files with different content")
    func ignoresSameSizeDifferentContent() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", data: Data(repeating: 1, count: 20000))
        try app.write("b.bin", data: Data(repeating: 2, count: 20000))

        let hits = try await RuleHarness.check(DuplicateResourceRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("reports each duplicate group separately, sorted by path")
    func reportsSeparateGroups() async throws {
        let app = try TemporaryApp()
        try app.write("z1.bin", data: Data(repeating: 1, count: 20000))
        try app.write("z2.bin", data: Data(repeating: 1, count: 20000))
        try app.write("a1.bin", data: Data(repeating: 2, count: 30000))
        try app.write("a2.bin", data: Data(repeating: 2, count: 30000))

        let hits = try await RuleHarness.check(DuplicateResourceRule(), in: app)

        #expect(hits.map(\.path) == ["a1.bin", "z1.bin"])
    }

    @Test("applies min_bytes with an inclusive lower bound")
    func appliesMinBytes() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 10240)
        try app.write("b.bin", size: 10240)
        try app.write("small1.bin", size: 10239)
        try app.write("small2.bin", size: 10239)

        let defaultHits = try await RuleHarness.check(DuplicateResourceRule(), in: app)
        let loweredHits = try await RuleHarness.check(DuplicateResourceRule(), in: app, settings: RuleSettings(minBytes: 10239))
        let raisedHits = try await RuleHarness.check(DuplicateResourceRule(), in: app, settings: RuleSettings(minBytes: 10241))

        #expect(defaultHits.map(\.path) == ["a.bin"])
        #expect(loweredHits.map(\.path) == ["a.bin", "small1.bin"])
        #expect(raisedHits.isEmpty)
    }

    @Test("ignores signing and provisioning files that are identical by design", arguments: [
        ["_CodeSignature/CodeResources", "PlugIns/X.appex/_CodeSignature/CodeResources"],
        ["Info.plist", "Frameworks/A.framework/Info.plist"],
        ["embedded.mobileprovision", "PlugIns/X.appex/embedded.mobileprovision"],
        ["PkgInfo", "Watch/W.app/PkgInfo"],
        ["CodeResources", "Other/CodeResources"],
        ["SC_Info/a.sinf", "SC_Info/b.sinf"],
    ])
    func ignoresSigningFiles(paths: [String]) async throws {
        let app = try TemporaryApp()
        for path in paths {
            try app.write(path, size: 20000)
        }

        let hits = try await RuleHarness.check(DuplicateResourceRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("defaults to warning severity in the waste category")
    func descriptor() {
        let descriptor = DuplicateResourceRule().descriptor

        #expect(descriptor.id == "duplicate-resource")
        #expect(descriptor.category == .waste)
        #expect(descriptor.defaultSeverity == .warning)
    }
}
