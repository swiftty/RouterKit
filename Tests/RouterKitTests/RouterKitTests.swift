import Testing
import Foundation
@testable import RouterKit

private func url(_ path: String = "", host: String = "example.com") -> URL {
    URL(string: "https://\(host)")!.appending(path: path)
}

struct RouterKitTests {
    @Test
    func testEmpty() {
        let router = Router<_, String>()
        #expect(router.route(url()) == nil)
    }

    @Test
    func testDefaultBehavior() {
        let router = Router<_, String>()
        router.register(#//foo/bar/#) { _ in "Hello, world!" }
        #expect(router.route(url("/foo/bar"))?.open() == "Hello, world!")
        #expect(router.route(url("/foo/bar/baz")) == nil)
    }

    @Test
    func testCapturePath() {
        let router = Router<_, String>()
        router.register(#//foo/(?<id>[0-9]+)/#) { String($0.path.id) }
        #expect(router.route(url("/foo/100"))?.open() == "100")
        #expect(router.route(url("/foo/bar")) == nil)
    }

    @Test
    func testDefaultAllowedHosts() {
        let router = Router<_, String>(defaultAllowedHosts: ["example.com"])
        router.register(#//foo/bar/#) { _ in "Hello, world!" }
        #expect(router.route(url("/foo/bar"))?.open() == "Hello, world!")
        #expect(router.route(url("/foo/bar", host: "example.net")) == nil)
    }

    @Test
    func testDefaultAllowedHostsIsEmpty() {
        let router = Router<_, String>(defaultAllowedHosts: [])
        router.register(#//foo/bar/#) { _ in "Hello, world!" }
        #expect(router.route(url("/foo/bar")) == nil)
        #expect(router.route(url("/foo/bar", host: "example.com")) == nil)

        router.register(#//foo/bar/baz/#, allowedHosts: .merge(["example.net"])) { _ in "Hello, world!" }
        #expect(router.route(url("/foo/bar/baz", host: "example.net"))?.open() == "Hello, world!")
        #expect(router.route(url("/foo/bar/baz")) == nil)
    }

    @Test
    func testAllowedHosts() {
        let router = Router<_, String>()
        router.register(#//foo/bar/#, allowedHosts: .only(["example.com"])) { _ in "Hello, world!" }
        #expect(router.route(url("/foo/bar"))?.open() == "Hello, world!")
        #expect(router.route(url("/foo/bar", host: "example.net")) == nil)
    }

    @Test
    func testMergedAllowedHosts() {
        let router = Router<_, String>(defaultAllowedHosts: ["example.com"])
        router.register(#//foo/bar/#, allowedHosts: .merge(["example.net"])) { _ in "Hello, world!" }
        #expect(router.route(url("/foo/bar"))?.open() == "Hello, world!")
        #expect(router.route(url("/foo/bar", host: "example.net"))?.open() == "Hello, world!")
        #expect(router.route(url("/foo/bar", host: "example.org")) == nil)
    }
}
