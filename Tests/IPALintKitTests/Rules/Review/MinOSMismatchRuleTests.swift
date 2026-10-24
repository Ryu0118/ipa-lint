@testable import IPALintKit
import Testing

struct MinOSMismatchRuleTests {
    @Test("accepts extensions whose minimum OS equals the app's, comparing numerically so 17 equals 17.0")
    func acceptsEqualVersions() async throws {
        let app = try makeApp(host: "17.0", extensions: ["PlugIns/A.appex": "17", "Extensions/B.appex": "17.0.0"])

        let hits = try await RuleHarness.check(MinOSMismatchRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("explains that a higher extension minimum will not load on the OS versions in between")
    func flagsHigherExtension() async throws {
        let app = try makeApp(host: "16.0", extensions: ["PlugIns/A.appex": "17.2"])

        let hits = try await RuleHarness.check(MinOSMismatchRule(), in: app)

        #expect(hits.map(\.path) == ["PlugIns/A.appex"])
        #expect(hits.first?.message.contains("will not load") == true)
        #expect(hits.first?.message.contains("17.2") == true)
        #expect(hits.first?.message.contains("16.0") == true)
    }

    @Test("explains that a lower extension minimum is inconsistent with the app")
    func flagsLowerExtension() async throws {
        let app = try makeApp(host: "17.0", extensions: ["Extensions/A.appex": "15.0"])

        let hits = try await RuleHarness.check(MinOSMismatchRule(), in: app)

        #expect(hits.map(\.path) == ["Extensions/A.appex"])
        #expect(hits.first?.message.contains("inconsistent") == true)
        #expect(hits.first?.message.contains("will not load") == false)
    }

    @Test("compares components as numbers, not strings: 9.3 is lower than 10.0")
    func comparesNumerically() async throws {
        let app = try makeApp(host: "9.3", extensions: ["PlugIns/A.appex": "10.0"])

        let hits = try await RuleHarness.check(MinOSMismatchRule(), in: app)

        #expect(hits.first?.message.contains("will not load") == true)
    }

    @Test("ignores extensions nested deeper, such as inside the watch app")
    func ignoresNestedExtensions() async throws {
        let app = try makeApp(host: "17.0", extensions: ["Watch/W.app/PlugIns/E.appex": "9.0"])
        try app.writePlist("Watch/W.app/Info.plist", ["MinimumOSVersion": "9.0"])

        let hits = try await RuleHarness.check(MinOSMismatchRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("skips the comparison when either version is missing")
    func skipsMissingVersions() async throws {
        let withoutHost = try makeApp(host: nil, extensions: ["PlugIns/A.appex": "17.0"])
        let withoutExtension = try makeApp(host: "17.0", extensions: [:])
        try withoutExtension.writePlist("PlugIns/A.appex/Info.plist", ["CFBundleIdentifier": "com.example.a"])

        let first = try await RuleHarness.check(MinOSMismatchRule(), in: withoutHost)
        let second = try await RuleHarness.check(MinOSMismatchRule(), in: withoutExtension)

        #expect(first.isEmpty)
        #expect(second.isEmpty)
    }

    @Test("reports each mismatching extension, in path order")
    func reportsEachExtension() async throws {
        let app = try makeApp(host: "17.0", extensions: ["PlugIns/B.appex": "18.0", "PlugIns/A.appex": "16.0", "PlugIns/C.appex": "17.0"])

        let hits = try await RuleHarness.check(MinOSMismatchRule(), in: app)

        #expect(hits.map(\.path) == ["PlugIns/A.appex", "PlugIns/B.appex"])
    }

    private func makeApp(host: String?, extensions: [String: String]) throws -> TemporaryApp {
        let app = try TemporaryApp()
        var hostPlist: [String: Any] = ["CFBundleIdentifier": "com.example.app"]
        hostPlist["MinimumOSVersion"] = host
        try app.writePlist("Info.plist", hostPlist)
        for (path, version) in extensions {
            try app.writePlist("\(path)/Info.plist", ["CFBundleIdentifier": "com.example.ext", "MinimumOSVersion": version])
        }
        return app
    }
}
