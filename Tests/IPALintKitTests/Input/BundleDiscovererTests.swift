@testable import IPALintKit
import Testing

struct BundleDiscovererTests {
    @Test("finds the app, extensions, frameworks, and watch apps, ignoring resource bundles")
    func discoversBundles() async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["CFBundleIdentifier": "com.example.app"])
        try app.writePlist("PlugIns/Widget.appex/Info.plist", ["CFBundleIdentifier": "com.example.app.widget"])
        try app.writePlist("Frameworks/Kit.framework/Info.plist", ["CFBundleIdentifier": "com.example.kit"])
        try app.writePlist("Watch/Watch.app/Info.plist", ["CFBundleIdentifier": "com.example.app.watch"])
        try app.writePlist("Feature.bundle/Info.plist", ["CFBundleIdentifier": "com.example.feature"])

        let contents = try await app.contents(entitlements: ["PlugIns/Widget.appex": ["get-task-allow": false]])

        #expect(contents.bundles.map(\.path) == ["", "Frameworks/Kit.framework", "PlugIns/Widget.appex", "Watch/Watch.app"])
        #expect(contents.bundles.map(\.kind) == [.application, .framework, .appExtension, .application])
        #expect(contents.bundles[2].entitlements == ["get-task-allow": .bool(false)])
        #expect(contents.bundles[0].infoPlist["CFBundleIdentifier"] == .string("com.example.app"))
    }

    @Test("lists regular files with their sizes and skips directories")
    func scansFiles() async throws {
        let app = try TemporaryApp()
        try app.write("a/b/c.bin", size: 3)
        try app.write("z.txt", text: "hello")

        let contents = try await app.contents()

        #expect(contents.files == [BundleFile(path: "a/b/c.bin", size: 3), BundleFile(path: "z.txt", size: 5)])
    }
}
