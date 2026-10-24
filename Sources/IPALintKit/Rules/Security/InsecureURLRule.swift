import Foundation

/// Flags development endpoints (local, private-network, and staging URLs) baked into the app.
package struct InsecureURLRule: LintRule {
    /// The rule's identity and defaults.
    package let descriptor = RuleDescriptor(
        id: "insecure-url",
        category: .security,
        defaultSeverity: .warning,
        summary: "A file contains a local, private-network, or staging URL that points at a development endpoint.",
    )

    private static let urlExpression = try! NSRegularExpression(pattern: #"(?i)\b(https?)://(\[[0-9a-f:]+\]|[a-z0-9._-]+)(:[0-9]+)?"#)
    private static let maximumListed = 3

    package init() {}

    /// Returns one hit per file, listing up to three distinct development URLs.
    package func check(_ context: RuleContext) -> [RuleHit] {
        ScannableText.texts(in: context, skippingFrameworks: true).compactMap { path, text in
            let urls = Self.developmentURLs(in: text)
            guard !urls.isEmpty else {
                return nil
            }
            return RuleHit(
                path: path,
                message: "Contains development endpoints (\(urls.prefix(Self.maximumListed).joined(separator: ", "))); development endpoints must not ship in a release build, so point them at production or inject them per configuration.",
            )
        }
    }

    private static func developmentURLs(in text: String) -> [String] {
        var urls: [String] = []
        for match in urlExpression.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            guard let whole = Range(match.range, in: text),
                  let scheme = Range(match.range(at: 1), in: text),
                  let host = Range(match.range(at: 2), in: text)
            else {
                continue
            }
            let url = String(text[whole])
            if !urls.contains(url), isDevelopment(scheme: text[scheme].lowercased(), host: text[host].lowercased()) {
                urls.append(url)
            }
        }
        return urls
    }

    private static func isDevelopment(scheme: String, host: String) -> Bool {
        let host = host.trimmingCharacters(in: CharacterSet(charactersIn: ".-"))
        if hasStagingLabel(host) {
            return true
        }
        return scheme == "http" && isLocalHost(host)
    }

    private static func hasStagingLabel(_ host: String) -> Bool {
        host.split(whereSeparator: { $0 == "." || $0 == "-" }).contains { $0 == "staging" || $0 == "stg" }
    }

    private static func isLocalHost(_ host: String) -> Bool {
        if ["localhost", "127.0.0.1", "0.0.0.0", "[::1]"].contains(host) {
            return true
        }
        let octets = host.split(separator: ".", omittingEmptySubsequences: false).compactMap { Int($0) }
        guard octets.count == 4, host.split(separator: ".").count == 4, octets.allSatisfy({ (0 ... 255).contains($0) }) else {
            return false
        }
        return octets[0] == 10 || (octets[0] == 192 && octets[1] == 168) || (octets[0] == 172 && (16 ... 31).contains(octets[1]))
    }
}
