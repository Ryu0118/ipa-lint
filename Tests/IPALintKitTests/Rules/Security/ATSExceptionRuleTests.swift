import Foundation
@testable import IPALintKit
import Testing

struct ATSExceptionRuleTests {
    @Test(
        "flags each arbitrary-loads key that is true",
        arguments: ["NSAllowsArbitraryLoads", "NSAllowsArbitraryLoadsInWebContent", "NSAllowsArbitraryLoadsForMedia"],
    )
    func arbitraryLoads(key: String) async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["NSAppTransportSecurity": [key: true]])

        let hits = try await RuleHarness.check(ATSExceptionRule(), in: app)

        #expect(hits.map(\.path) == ["Info.plist"])
        #expect(hits[0].message.contains(key))
    }

    @Test("does not flag false values, local networking, or a missing ATS dictionary")
    func ignoresSafe() async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["NSAppTransportSecurity": [
            "NSAllowsArbitraryLoads": false,
            "NSAllowsLocalNetworking": true,
            "NSExceptionDomains": ["example.com": ["NSExceptionAllowsInsecureHTTPLoads": false, "NSIncludesSubdomains": true]],
        ]])
        try app.writePlist("PlugIns/W.appex/Info.plist", ["CFBundleIdentifier": "x"])

        #expect(try await RuleHarness.check(ATSExceptionRule(), in: app).isEmpty)
    }

    @Test(
        "names each exception domain that allows insecure HTTP",
        arguments: ["NSExceptionAllowsInsecureHTTPLoads", "NSTemporaryExceptionAllowsInsecureHTTPLoads"],
    )
    func insecureDomains(key: String) async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["NSAppTransportSecurity": ["NSExceptionDomains": [
            "bad.example.com": [key: true],
            "good.example.com": [key: false],
            "other.example.com": [key: true],
        ]]])

        let hits = try await RuleHarness.check(ATSExceptionRule(), in: app)

        #expect(hits.count == 2)
        #expect(hits[0].message.contains("bad.example.com"))
        #expect(hits[1].message.contains("other.example.com"))
    }

    @Test("checks extensions and frameworks and reports against their own Info.plist")
    func nestedBundles() async throws {
        let app = try TemporaryApp()
        try app.writePlist("Info.plist", ["CFBundleIdentifier": "app"])
        try app.writePlist("PlugIns/W.appex/Info.plist", ["NSAppTransportSecurity": ["NSAllowsArbitraryLoads": true]])
        try app.writePlist("Frameworks/K.framework/Info.plist", ["NSAppTransportSecurity": ["NSAllowsArbitraryLoadsForMedia": true]])

        let hits = try await RuleHarness.check(ATSExceptionRule(), in: app)

        #expect(Set(hits.map(\.path)) == ["PlugIns/W.appex/Info.plist", "Frameworks/K.framework/Info.plist"])
    }
}
