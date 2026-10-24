@testable import IPALintKit
import Testing

struct SourceFileRuleTests {
    @Test("flags source and tooling files by extension or exact name", arguments: [
        "Main.swift", "a.m", "a.mm", "a.c", "a.cc", "a.cpp", "README.md", "notes.markdown",
        "build.sh", "tool.py", "tool.rb", "ci.yml", "ci.yaml", "Debug.xcconfig", "a.orig", "a.rej", "run.log",
        "Support.h", "Resources/.DS_Store", "Podfile", "Podfile.lock", "Package.swift", "Package.resolved",
        "Cartfile", "Makefile",
    ])
    func flagsSourceFiles(path: String) async throws {
        let app = try TemporaryApp()
        try app.write(path, size: 8)

        let hits = try await RuleHarness.check(SourceFileRule(), in: app)

        #expect(hits.map(\.path) == [path])
    }

    @Test("leaves runtime resources and framework headers alone", arguments: [
        "Info.plist",
        "icon.png",
        "swift.json",
        "Makefile.txt",
        "Frameworks/A.framework/Headers/A.h",
        "Frameworks/A.framework/PrivateHeaders/A.h",
        "PlugIns/X.appex/Frameworks/A.framework/Headers/Sub/B.h",
    ])
    func ignoresRuntimeFiles(path: String) async throws {
        let app = try TemporaryApp()
        try app.write(path, size: 8)

        let hits = try await RuleHarness.check(SourceFileRule(), in: app)

        #expect(hits.isEmpty)
    }

    @Test("still flags headers outside a framework Headers directory and non-header sources inside frameworks")
    func flagsHeadersOutsideFrameworks() async throws {
        let app = try TemporaryApp()
        try app.write("Headers/A.h", size: 8)
        try app.write("Frameworks/A.framework/Other/A.h", size: 8)
        try app.write("Frameworks/A.framework/Headers/A.swift", size: 8)

        let hits = try await RuleHarness.check(SourceFileRule(), in: app)

        #expect(hits.map(\.path) == ["Frameworks/A.framework/Headers/A.swift", "Frameworks/A.framework/Other/A.h", "Headers/A.h"])
    }

    @Test("defaults to error severity in the waste category")
    func descriptor() {
        let descriptor = SourceFileRule().descriptor

        #expect(descriptor.id == "source-file")
        #expect(descriptor.category == .waste)
        #expect(descriptor.defaultSeverity == .error)
    }
}
