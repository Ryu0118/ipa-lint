@testable import IPALintKit
import Testing

struct DevArtifactRuleTests {
    @Test("flags test and development data by extension, file name prefix, or directory name", arguments: [
        "Smoke.xctestplan",
        "Plans/Release.xctestplan",
        "Results/Run.xcresult/Info.plist",
        "mock-response.json",
        "Data/MockUser.json",
        "Fixtures/user.json",
        "Resources/TestData/a.bin",
        "Fixtures/a.bin",
        "Tests/__Snapshots__/home.png",
        "Preview Content/preview.png",
    ])
    func flagsDevelopmentData(path: String) async throws {
        let app = try TemporaryApp()
        try app.write(path, size: 8)

        let hits = try await RuleHarness.check(DevArtifactRule(), in: app)

        #expect(hits.map(\.path) == [path])
    }

    @Test("leaves ordinary resources alone, including near-miss names", arguments: [
        "Info.plist",
        "Smoke.xctestplan.txt",
        "mockup.png",
        "mock.json",
        "Data/Demock.json",
        "TestDatas/a.bin",
        "testdata/a.bin",
        "Fixture/a.bin",
    ])
    func ignoresOrdinaryResources(path: String) async throws {
        let app = try TemporaryApp()
        try app.write(path, size: 8)

        let hits = try await RuleHarness.check(DevArtifactRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("reports one hit per file even when several conditions match, sorted by path")
    func reportsOneHitPerFile() async throws {
        let app = try TemporaryApp()
        try app.write("b/Fixtures/mock-a.bin", size: 8)
        try app.write("a.xctestplan", size: 8)

        let hits = try await RuleHarness.check(DevArtifactRule(), in: app)

        #expect(hits.map(\.path) == ["a.xctestplan", "b/Fixtures/mock-a.bin"])
    }

    @Test("defaults to error severity in the waste category")
    func descriptor() {
        let descriptor = DevArtifactRule().descriptor

        #expect(descriptor.id == "dev-artifact")
        #expect(descriptor.category == .waste)
        #expect(descriptor.defaultSeverity == .error)
    }
}
