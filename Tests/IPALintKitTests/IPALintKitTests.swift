@testable import IPALintKit
import Testing

struct IPALintKitTests {
    @Test("returns the starter greeting")
    func greeting() {
        #expect(IPALintKit.greeting() == "Hello from IPALint")
    }
}
