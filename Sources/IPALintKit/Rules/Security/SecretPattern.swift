import Foundation

/// A named regular expression for one kind of secret.
struct SecretPattern: Sendable {
    let name: String
    let expression: NSRegularExpression

    init(_ name: String, _ pattern: String) {
        self.name = name
        expression = try! NSRegularExpression(pattern: pattern)
    }

    /// The first match in `text`, or nil.
    func firstMatch(in text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)
        return expression.firstMatch(in: text, range: range).flatMap { Range($0.range, in: text) }.map { String(text[$0]) }
    }
}

extension SecretPattern {
    /// Google API keys (`AIza...`) are left out on purpose: Firebase ships them in GoogleService-Info.plist.
    static let all: [SecretPattern] = [
        SecretPattern("AWS access key ID", #"\b(AKIA|ASIA)[0-9A-Z]{16}\b"#),
        SecretPattern("private key", #"-----BEGIN ((RSA|EC|DSA|OPENSSH|ENCRYPTED) )?PRIVATE KEY-----"#),
        SecretPattern("GitHub token", #"\bgh[pousr]_[A-Za-z0-9]{36}\b"#),
        SecretPattern("GitHub fine-grained token", #"\bgithub_pat_[A-Za-z0-9_]{60,}"#),
        SecretPattern("Slack token", #"\bxox[abprs]-[A-Za-z0-9-]{10,}"#),
        SecretPattern("Stripe live secret key", #"\b(sk|rk)_live_[A-Za-z0-9]{20,}"#),
        SecretPattern("Anthropic API key", #"\bsk-ant-[A-Za-z0-9_-]{32,}"#),
        SecretPattern("OpenAI API key", #"\bsk-(?!ant-)(proj-)?[A-Za-z0-9_-]{32,}"#),
    ]
}
