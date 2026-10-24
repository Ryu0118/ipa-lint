import Foundation
@testable import IPALintKit
import Testing

struct EmbeddedSecretRuleTests {
    /// Secrets are assembled at runtime so this file never contains a literal that secret scanners would flag.
    private static let samples: [(name: String, secret: String)] = [
        ("AWS access key ID", "AK" + "IA" + String(repeating: "Q", count: 16)),
        ("AWS access key ID", "AS" + "IA" + String(repeating: "7", count: 16)),
        ("private key", "-----BEGIN " + "PRIVATE KEY-----"),
        ("private key", "-----BEGIN " + "RSA PRIVATE KEY-----"),
        ("GitHub token", "gh" + "p_" + String(repeating: "a", count: 36)),
        ("GitHub fine-grained token", "github" + "_pat_" + String(repeating: "B", count: 70)),
        ("Slack token", "xo" + "xb-" + "1234567890-abcdefghij"),
        ("Stripe live secret key", "sk" + "_live_" + String(repeating: "z", count: 24)),
        ("Anthropic API key", "sk-" + "ant-" + String(repeating: "c", count: 40)),
        ("OpenAI API key", "sk-" + "proj-" + String(repeating: "d", count: 40)),
        ("OpenAI API key", "sk-" + String(repeating: "e", count: 40)),
    ]

    @Test("detects each secret kind in a binary-like file and names the kind", arguments: samples)
    func detects(name: String, secret: String) async throws {
        let app = try TemporaryApp()
        let blob = Data([0x00, 0x01]) + Data("config=\(secret);".utf8) + Data([0x02, 0x00])
        try app.write("Resources/blob.bin", data: blob)

        let hits = try await RuleHarness.check(EmbeddedSecretRule(), in: app)

        #expect(hits.count == 1)
        #expect(hits[0].path == "Resources/blob.bin")
        #expect(hits[0].message.contains(name))
    }

    @Test("shows only a four-character prefix of the secret")
    func redacts() async throws {
        let app = try TemporaryApp()
        let secret = "gh" + "p_" + String(repeating: "k", count: 36)
        try app.write("a.txt", text: secret)

        let message = try #require(await RuleHarness.check(EmbeddedSecretRule(), in: app).first).message

        #expect(message.contains("ghp_…"))
        #expect(!message.contains(String(secret.dropFirst(5))))
        #expect(message.contains("rotate"))
    }

    @Test("reports an Anthropic key once, as Anthropic and not as OpenAI")
    func anthropicNotOpenAI() async throws {
        let app = try TemporaryApp()
        try app.write("a.txt", text: "sk-" + "ant-api03-" + String(repeating: "x", count: 40))

        let hits = try await RuleHarness.check(EmbeddedSecretRule(), in: app)

        #expect(hits.count == 1)
        #expect(hits[0].message.contains("Anthropic"))
    }

    @Test("reports one hit per file and kind even when a secret repeats")
    func oneHitPerKind() async throws {
        let app = try TemporaryApp()
        let key = "AK" + "IA" + String(repeating: "Q", count: 16)
        try app.write("a.txt", text: "\(key)\n\(key)\n" + "-----BEGIN " + "PRIVATE KEY-----")

        #expect(try await RuleHarness.check(EmbeddedSecretRule(), in: app).count == 2)
    }

    @Test("does not flag Google API keys, short or malformed tokens, or lowercase AWS-like ids")
    func ignoresNonSecrets() async throws {
        let app = try TemporaryApp()
        try app.writePlist("GoogleService-Info.plist", ["API_KEY": "AI" + "za" + String(repeating: "S", count: 35)])
        try app.write("b.txt", text: "AK" + "IA" + "SHORT and ak" + "ia" + String(repeating: "q", count: 16) + " sk-short xoxb-1 ghp_tooshort")

        #expect(try await RuleHarness.check(EmbeddedSecretRule(), in: app).isEmpty)
    }

    @Test("skips code signatures, provisioning profiles, assets, and media")
    func skipsExcluded() async throws {
        let app = try TemporaryApp()
        let secret = "gh" + "p_" + String(repeating: "a", count: 36)
        for path in ["_CodeSignature/CodeResources", "embedded.mobileprovision", "Assets.car", "a.png", "b.JPG", "c.mp4", "d.ttf", "e.pdf"] {
            try app.write(path, text: secret)
        }

        #expect(try await RuleHarness.check(EmbeddedSecretRule(), in: app).isEmpty)
    }

    @Test("scans inside frameworks, unlike the URL rule")
    func scansFrameworks() async throws {
        let app = try TemporaryApp()
        try app.write("Frameworks/K.framework/data", text: "AK" + "IA" + String(repeating: "Q", count: 16))

        #expect(try await RuleHarness.check(EmbeddedSecretRule(), in: app).map(\.path) == ["Frameworks/K.framework/data"])
    }
}
