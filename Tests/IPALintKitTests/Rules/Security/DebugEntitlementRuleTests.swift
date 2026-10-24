import Foundation
@testable import IPALintKit
import Testing

struct DebugEntitlementRuleTests {
    @Test(
        "flags each development entitlement value",
        arguments: [
            ("get-task-allow", true as any Sendable),
            ("aps-environment", "development"),
            ("com.apple.developer.icloud-container-environment", "Development"),
            ("com.apple.developer.devicecheck.appattest-environment", "development"),
        ] as [(String, any Sendable)],
    )
    func flagsDevelopmentValue(key: String, value: any Sendable) async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["CFBundleIdentifier": "app"])

        let hits = try await RuleHarness.check(DebugEntitlementRule(), in: app, entitlements: ["": [key: value]])

        #expect(hits.map(\.path) == ["."])
        #expect(hits[0].message.contains(key))
    }

    @Test(
        "does not flag production values",
        arguments: [
            ("get-task-allow", false as any Sendable),
            ("aps-environment", "production"),
            ("com.apple.developer.icloud-container-environment", "Production"),
            ("com.apple.developer.devicecheck.appattest-environment", "production"),
        ] as [(String, any Sendable)],
    )
    func ignoresProduction(key: String, value: any Sendable) async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["CFBundleIdentifier": "app"])

        #expect(try await RuleHarness.check(DebugEntitlementRule(), in: app, entitlements: ["": [key: value]]).isEmpty)
    }

    @Test("reports one hit per offending key per bundle, using the bundle directory as the path")
    func perBundle() async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["CFBundleIdentifier": "app"])
        try app.writePlist("PlugIns/W.appex/Info.plist", ["CFBundleIdentifier": "w"])

        let hits = try await RuleHarness.check(DebugEntitlementRule(), in: app, entitlements: [
            "": ["get-task-allow": true],
            "PlugIns/W.appex": ["get-task-allow": true, "aps-environment": "development"],
        ])

        #expect(hits.map(\.path) == [".", "PlugIns/W.appex", "PlugIns/W.appex"])
    }
}
