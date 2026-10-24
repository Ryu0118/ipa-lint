@testable import IPALintKit
import Testing

struct MissingPrivacyManifestRuleTests {
    private static let manifest = "PrivacyInfo.xcprivacy"

    @Test("flags the app and a framework that ship without a manifest, in path order")
    func flagsAppAndFramework() async throws {
        let app = try makeApp(appManifest: false, frameworkManifest: false)

        let hits = try await RuleHarness.check(MissingPrivacyManifestRule(), in: app)

        #expect(hits.map(\.path) == [".", "Frameworks/Kit.framework"])
    }

    @Test("accepts an app and a framework that each contain a manifest")
    func acceptsManifests() async throws {
        let app = try makeApp(appManifest: true, frameworkManifest: true)

        let hits = try await RuleHarness.check(MissingPrivacyManifestRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("checks each bundle separately: a manifest in the app does not cover a framework")
    func checksEachBundle() async throws {
        let app = try makeApp(appManifest: true, frameworkManifest: false)

        let hits = try await RuleHarness.check(MissingPrivacyManifestRule(), in: app)

        #expect(hits.map(\.path) == ["Frameworks/Kit.framework"])
    }

    @Test("accepts a framework whose manifest sits in a nested resource bundle, as SwiftPM-built SDKs ship it")
    func acceptsNestedFrameworkManifest() async throws {
        let app = try makeApp(appManifest: true, frameworkManifest: false)
        try app.write("Frameworks/Kit.framework/Kit_Privacy.bundle/\(Self.manifest)", size: 4)

        let hits = try await RuleHarness.check(MissingPrivacyManifestRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("requires the app's own manifest at its root: a package's resource bundle does not cover the app")
    func requiresAppManifestAtRoot() async throws {
        let app = try makeApp(appManifest: false, frameworkManifest: true)
        try app.write("Lottie_Lottie.bundle/\(Self.manifest)", size: 4)

        let hits = try await RuleHarness.check(MissingPrivacyManifestRule(), in: app)

        #expect(hits.map(\.path) == ["."])
    }

    @Test("does not require a manifest in extensions")
    func ignoresExtensions() async throws {
        let app = try makeApp(appManifest: true, frameworkManifest: true)
        try app.writePlist("PlugIns/Widget.appex/Info.plist", ["CFBundleIdentifier": "com.example.widget"])

        let hits = try await RuleHarness.check(MissingPrivacyManifestRule(), in: app)

        #expect(hits.isEmpty)
    }

    private func makeApp(appManifest: Bool, frameworkManifest: Bool) throws -> TemporaryApp {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["CFBundleIdentifier": "com.example.app"])
        try app.writePlist("Frameworks/Kit.framework/Info.plist", ["CFBundleIdentifier": "com.example.kit"])
        if appManifest {
            try app.write(Self.manifest, size: 4)
        }
        if frameworkManifest {
            try app.write("Frameworks/Kit.framework/\(Self.manifest)", size: 4)
        }
        return app
    }
}
