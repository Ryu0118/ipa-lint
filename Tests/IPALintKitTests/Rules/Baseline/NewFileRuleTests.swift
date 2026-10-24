@testable import IPALintKit
import Testing

struct NewFileRuleTests {
    @Test("reports nothing when no baseline was given")
    func noBaseline() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 10)

        let hits = try await RuleHarness.check(NewFileRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("flags files missing from the baseline with their size, and not files already in it")
    func flagsNewFiles() async throws {
        let app = try TemporaryApp()
        try app.write("old.bin", size: 10)
        try app.write("new/b.bin", size: 2048)
        try app.write("new/a.bin", size: 5)
        let baseline = BundleSnapshot(files: [BundleFile(path: "old.bin", size: 99), BundleFile(path: "gone.bin", size: 1)], entitlements: [:])

        let hits = try await RuleHarness.check(NewFileRule(), in: app, baseline: baseline)

        #expect(hits.map(\.path) == ["new/a.bin", "new/b.bin"])
        #expect(hits[1].message.contains("2048 bytes"))
    }

    @Test("reports nothing when every file is in the baseline")
    func nothingNew() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 10)
        let baseline = BundleSnapshot(files: [BundleFile(path: "a.bin", size: 10)], entitlements: [:])

        let hits = try await RuleHarness.check(NewFileRule(), in: app, baseline: baseline)

        #expect(hits.isEmpty)
    }
}
