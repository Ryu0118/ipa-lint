@testable import IPALintKit
import Testing

struct SizeGrowthRuleTests {
    private static let megabyte = 1_048_576

    @Test("reports nothing without a baseline")
    func noBaseline() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 3 * Self.megabyte)

        let hits = try await RuleHarness.check(SizeGrowthRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("reports total growth beyond the default 1 MB with before, after, and delta in MB")
    func totalGrowth() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 3 * Self.megabyte)
        let baseline = BundleSnapshot(files: [BundleFile(path: "a.bin", size: Self.megabyte / 2)], entitlements: [:])

        let hits = try await RuleHarness.check(SizeGrowthRule(), in: app, baseline: baseline)

        let total = try #require(hits.first { $0.path == "." })
        #expect(total.message.contains("0.5 MB"))
        #expect(total.message.contains("3.0 MB"))
        #expect(total.message.contains("2.5 MB"))
    }

    @Test("reports a file that grew beyond the threshold at its own path")
    func fileGrowth() async throws {
        let app = try TemporaryApp()
        try app.write("big.bin", size: 5 * Self.megabyte)
        try app.write("small.bin", size: 10)
        let baseline = BundleSnapshot(
            files: [BundleFile(path: "big.bin", size: Self.megabyte), BundleFile(path: "small.bin", size: 1)],
            entitlements: [:],
        )

        let hits = try await RuleHarness.check(SizeGrowthRule(), in: app, baseline: baseline)

        #expect(hits.map(\.path) == [".", "big.bin"])
    }

    @Test("does not report growth that equals the threshold exactly")
    func thresholdIsExclusive() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 2 * Self.megabyte)
        let baseline = BundleSnapshot(files: [BundleFile(path: "a.bin", size: Self.megabyte)], entitlements: [:])

        let hits = try await RuleHarness.check(SizeGrowthRule(), in: app, baseline: baseline)

        #expect(hits.isEmpty)
    }

    @Test("does not report files that shrank or total size that shrank")
    func shrinkIsFine() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 10)
        let baseline = BundleSnapshot(files: [BundleFile(path: "a.bin", size: 9 * Self.megabyte)], entitlements: [:])

        let hits = try await RuleHarness.check(SizeGrowthRule(), in: app, baseline: baseline)

        #expect(hits.isEmpty)
    }

    @Test("a new file counts toward total growth but is not a per-file hit")
    func newFilesOnlyAffectTotal() async throws {
        let app = try TemporaryApp()
        try app.write("new.bin", size: 4 * Self.megabyte)
        let baseline = BundleSnapshot(files: [], entitlements: [:])

        let hits = try await RuleHarness.check(SizeGrowthRule(), in: app, baseline: baseline)

        #expect(hits.map(\.path) == ["."])
    }

    @Test("uses max_bytes from the settings as the threshold")
    func customThreshold() async throws {
        let app = try TemporaryApp()
        try app.write("a.bin", size: 1500)
        let baseline = BundleSnapshot(files: [BundleFile(path: "a.bin", size: 1000)], entitlements: [:])

        let hits = try await RuleHarness.check(SizeGrowthRule(), in: app, settings: RuleSettings(maxBytes: 100), baseline: baseline)

        #expect(hits.map(\.path) == [".", "a.bin"])
    }
}
