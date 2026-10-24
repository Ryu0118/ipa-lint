import Foundation
@testable import IPALintKit
import Testing

struct CredentialFileRuleTests {
    @Test(
        "flags key, credential, and provisioning files anywhere in the app",
        arguments: [
            "AuthKey_ABC.p8", "cert.p12", "Resources/cert.PFX", "ca.pem", "private.key", "release.jks", "debug.keystore",
            ".env", "Config/.env.production", ".netrc", "id_rsa", "ssh/id_ecdsa", "id_ed25519",
            "Other.mobileprovision", "Frameworks/Kit.framework/embedded.mobileprovision", "Sub/embedded.mobileprovision",
        ],
    )
    func flagsCredential(path: String) async throws {
        let app = try TemporaryApp()
        try app.write(path, text: "x")

        let hits = try await RuleHarness.check(CredentialFileRule(), in: app)

        #expect(hits.map(\.path) == [path])
    }

    @Test(
        "does not flag embedded profiles at a bundle root or similar-looking names",
        arguments: [
            "embedded.mobileprovision", "PlugIns/W.appex/embedded.mobileprovision", "Watch/Watch.app/embedded.mobileprovision",
            "environment.txt", "env", "keyboard.json", "monkey", "id_rsa.pub", "Assets/key.png",
        ],
    )
    func ignoresOrdinary(path: String) async throws {
        let app = try TemporaryApp()
        try app.write(path, text: "x")

        #expect(try await RuleHarness.check(CredentialFileRule(), in: app).isEmpty)
    }

    @Test("reports one hit per file, sorted by path, with a remediation message")
    func hitShape() async throws {
        let app = try TemporaryApp()
        try app.write("b.pem", text: "x")
        try app.write("a.p8", text: "x")

        let hits = try await RuleHarness.check(CredentialFileRule(), in: app)

        #expect(hits.map(\.path) == ["a.p8", "b.pem"])
        #expect(hits[0].message.contains("rotate"))
    }
}
