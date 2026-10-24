import Foundation
@testable import IPALintKit
import Testing

struct InsecureURLRuleTests {
    @Test(
        "flags http URLs to local and private hosts and staging hosts over any scheme",
        arguments: [
            "http://localhost:8080/api", "http://127.0.0.1/x", "http://0.0.0.0:3000", "http://[::1]:8000/", "http://10.1.2.3/a",
            "http://192.168.0.5", "http://172.16.0.1", "http://172.31.255.255", "HTTP://LOCALHOST/",
            "https://api.staging.example.com", "https://stg-api.example.com/v1", "http://staging.example.com", "https://example.stg.io",
        ],
    )
    func flags(url: String) async throws {
        let app = try TemporaryApp()
        try app.write("Config.json", text: "{\"base\": \"\(url)\"}")

        let hits = try await RuleHarness.check(InsecureURLRule(), in: app)

        #expect(hits.map(\.path) == ["Config.json"])
        #expect(hits[0].message.contains("release build"))
    }

    @Test(
        "does not flag https to local hosts, public or out-of-range addresses, or look-alike names",
        arguments: [
            "https://localhost/", "http://example.com", "http://172.15.0.1", "http://172.32.0.1", "http://11.0.0.1", "http://192.169.0.1",
            "http://10.0.0.1.example.com", "https://api.example.com", "https://stagingarea.example.com", "http://www.w3.org/2000/svg",
        ],
    )
    func ignores(url: String) async throws {
        let app = try TemporaryApp()
        try app.write("Config.json", text: "{\"base\": \"\(url)\"}")

        #expect(try await RuleHarness.check(InsecureURLRule(), in: app).isEmpty)
    }

    @Test("lists at most three distinct URLs in a single hit per file")
    func capsAtThree() async throws {
        let app = try TemporaryApp()
        try app.write("a.txt", text: "http://localhost/a http://localhost/b http://10.0.0.1 http://10.0.0.2 http://10.0.0.3 http://localhost/c")

        let hits = try await RuleHarness.check(InsecureURLRule(), in: app)

        #expect(hits.count == 1)
        #expect(hits[0].message.contains("http://localhost, http://10.0.0.1, http://10.0.0.2"))
        #expect(!hits[0].message.contains("10.0.0.3"))
    }

    @Test("skips frameworks, code signatures, provisioning profiles, and media")
    func skipsExcluded() async throws {
        let app = try TemporaryApp()
        for path in ["Frameworks/K.framework/K", "_CodeSignature/CodeResources", "embedded.mobileprovision", "Assets.car", "a.png"] {
            try app.write(path, text: "http://localhost:8080/")
        }

        #expect(try await RuleHarness.check(InsecureURLRule(), in: app).isEmpty)
    }
}

struct ScannableTextTests {
    @Test("excludes files above 100 MB but keeps files at the limit")
    func sizeLimit() {
        #expect(ScannableText.isScannable(path: "big.bin", size: 100 * 1024 * 1024, skippingFrameworks: false))
        #expect(!ScannableText.isScannable(path: "big.bin", size: 100 * 1024 * 1024 + 1, skippingFrameworks: false))
    }
}
