@testable import IPALintKit
import Testing

struct PathPatternTests {
    @Test(
        "matches a slash-free pattern against the file name at any depth, and a slashed one against the whole path",
        arguments: [
            ("mock-*.json", "mock-data.json", true),
            ("mock-*.json", "Sub.bundle/mock-data.json", true),
            ("mock-*.json", "mock.json", false),
            ("Frameworks/*/Headers/*", "Frameworks/A.framework/Headers/A.h", true),
            ("Frameworks/*/Headers/*", "PlugIns/A.appex/Frameworks/A.framework/Headers/A.h", false),
            ("*/Headers/*", "PlugIns/A.appex/Frameworks/A.framework/Headers/A.h", true),
        ],
    )
    func matching(pattern: String, path: String, expected: Bool) {
        #expect(PathPattern(pattern).matches(path) == expected)
    }
}
