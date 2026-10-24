@testable import IPALintKit
import Testing

struct NewEntitlementRuleTests {
    @Test("reports nothing without a baseline")
    func noBaseline() async throws {
        let app = try makeApp()

        let hits = try await RuleHarness.check(NewEntitlementRule(), in: app, entitlements: ["": ["aps-environment": "production"]])

        #expect(hits.isEmpty)
    }

    @Test("reports an added key and a changed value, one hit per key, and not an unchanged key")
    func addedAndChanged() async throws {
        let app = try makeApp()
        let baseline = BundleSnapshot(
            files: [],
            entitlements: ["": ["aps-environment": .string("development"), "keep": .bool(true)]],
        )

        let hits = try await RuleHarness.check(
            NewEntitlementRule(),
            in: app,
            entitlements: ["": ["aps-environment": "production", "keep": true, "com.apple.developer.healthkit": true]],
            baseline: baseline,
        )

        #expect(hits.map(\.path) == [".", "."])
        #expect(hits.map(\.message).contains { $0.contains("adds entitlement com.apple.developer.healthkit") })
        #expect(hits.map(\.message).contains { $0.contains("changes entitlement aps-environment") })
        #expect(!hits.map(\.message).contains { $0.contains("keep") })
    }

    @Test("treats a bundle missing from the baseline as having no entitlements, and reports at the bundle directory")
    func newBundle() async throws {
        let app = try makeApp()
        let baseline = BundleSnapshot(files: [], entitlements: [:])

        let hits = try await RuleHarness.check(
            NewEntitlementRule(),
            in: app,
            entitlements: ["PlugIns/Widget.appex": ["com.apple.security.application-groups": ["group.a"]]],
            baseline: baseline,
        )

        #expect(hits.map(\.path) == ["PlugIns/Widget.appex"])
        #expect(hits.first?.message.contains("adds entitlement com.apple.security.application-groups") == true)
    }

    @Test("reports nothing when the entitlements match the baseline or were removed")
    func unchangedOrRemoved() async throws {
        let app = try makeApp()
        let baseline = BundleSnapshot(files: [], entitlements: ["": ["a": .bool(true), "removed": .bool(true)]])

        let hits = try await RuleHarness.check(NewEntitlementRule(), in: app, entitlements: ["": ["a": true]], baseline: baseline)

        #expect(hits.isEmpty)
    }

    @Test("keys are compared per bundle: the same key in a different bundle is new")
    func perBundle() async throws {
        let app = try makeApp()
        let baseline = BundleSnapshot(files: [], entitlements: ["": ["a": .bool(true)]])

        let hits = try await RuleHarness.check(
            NewEntitlementRule(),
            in: app,
            entitlements: ["": ["a": true], "PlugIns/Widget.appex": ["a": true]],
            baseline: baseline,
        )

        #expect(hits.map(\.path) == ["PlugIns/Widget.appex"])
    }

    private func makeApp() throws -> TemporaryApp {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["CFBundleIdentifier": "com.example.app"])
        try app.writePlist("PlugIns/Widget.appex/Info.plist", ["CFBundleIdentifier": "com.example.widget"])
        return app
    }
}
