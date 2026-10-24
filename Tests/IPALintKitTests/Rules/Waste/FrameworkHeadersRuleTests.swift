@testable import IPALintKit
import Testing

struct FrameworkHeadersRuleTests {
    @Test("reports one hit per framework directory with file count and size")
    func summarizesPerDirectory() async throws {
        let app = try TemporaryApp()
        try app.write("Frameworks/A.framework/Headers/A.h", size: 1024)
        try app.write("Frameworks/A.framework/Headers/Sub/B.h", size: 2048)
        try app.write("Frameworks/A.framework/PrivateHeaders/P.h", size: 10)
        try app.write("Frameworks/A.framework/Modules/module.modulemap", size: 10)
        try app.write("Frameworks/A.framework/A", size: 100)

        let hits = try await RuleHarness.check(FrameworkHeadersRule(), in: app)

        #expect(hits.map(\.path) == [
            "Frameworks/A.framework/Headers",
            "Frameworks/A.framework/Modules",
            "Frameworks/A.framework/PrivateHeaders",
        ])
        #expect(hits[0].message.contains("2 files (3 KB)"))
        #expect(hits[1].message.contains("1 file ("))
    }

    @Test("handles frameworks nested in extensions and keeps frameworks separate")
    func handlesNestedFrameworks() async throws {
        let app = try TemporaryApp()
        try app.write("PlugIns/X.appex/Frameworks/A.framework/Modules/m.modulemap", size: 10)
        try app.write("Frameworks/B.framework/Headers/B.h", size: 10)

        let hits = try await RuleHarness.check(FrameworkHeadersRule(), in: app)

        #expect(hits.map(\.path) == [
            "Frameworks/B.framework/Headers",
            "PlugIns/X.appex/Frameworks/A.framework/Modules",
        ])
    }

    @Test("ignores headers outside frameworks and files directly in the framework")
    func ignoresNonFrameworkHeaders() async throws {
        let app = try TemporaryApp()
        try app.write("Headers/A.h", size: 10)
        try app.write("Modules/m.modulemap", size: 10)
        try app.write("Frameworks/A.framework/Headers", size: 10)
        try app.write("Frameworks/A.framework/Resources/Headers.txt", size: 10)

        let hits = try await RuleHarness.check(FrameworkHeadersRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("defaults to warning severity in the waste category")
    func descriptor() {
        let descriptor = FrameworkHeadersRule().descriptor

        #expect(descriptor.id == "framework-headers")
        #expect(descriptor.category == .waste)
        #expect(descriptor.defaultSeverity == .warning)
    }
}
