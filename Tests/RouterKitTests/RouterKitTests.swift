import XCTest
@testable import RouterKit

private func url(_ path: String = "", host: String = "example.com") -> URL {
    URL(string: "https://\(host)")!.appending(path: path)
}

final class RouterKitTests: XCTestCase {
    func testEmpty() {
        let router = Router<_, String>()
        XCTAssertNil(router.route(url()))
    }

    func testDefaultBehavior() {
        let router = Router<_, String>()
        router.register(#//foo/bar/#) { _ in "Hello, world!" }
        XCTAssertEqual(router.route(url("/foo/bar"))?.open(), "Hello, world!")
        XCTAssertNil(router.route(url("/foo/bar/baz")))
    }

    func testCapturePath() {
        let router = Router<_, String>()
        router.register(#//foo/(?<id>[0-9]+)/#) { String($0.path.id) }
        XCTAssertEqual(router.route(url("/foo/100"))?.open(), "100")
        XCTAssertNil(router.route(url("/foo/bar")))
    }

    func testDefaultAllowedHosts() {
        let router = Router<_, String>(defaultAllowedHosts: ["example.com"])
        router.register(#//foo/bar/#) { _ in "Hello, world!" }
        XCTAssertEqual(router.route(url("/foo/bar"))?.open(), "Hello, world!")
        XCTAssertNil(router.route(url("/foo/bar", host: "example.net")))
    }

    func testDefaultAllowedHostsIsEmpty() {
        let router = Router<_, String>(defaultAllowedHosts: [])
        router.register(#//foo/bar/#) { _ in "Hello, world!" }
        XCTAssertNil(router.route(url("/foo/bar")))
        XCTAssertNil(router.route(url("/foo/bar", host: "example.com")))

        router.register(#//foo/bar/baz/#, allowedHosts: .merge(["example.net"])) { _ in "Hello, world!" }
        XCTAssertEqual(router.route(url("/foo/bar/baz", host: "example.net"))?.open(), "Hello, world!")
        XCTAssertNil(router.route(url("/foo/bar/baz")))
    }

    func testAllowedHosts() {
        let router = Router<_, String>()
        router.register(#//foo/bar/#, allowedHosts: .only(["example.com"])) { _ in "Hello, world!" }
        XCTAssertEqual(router.route(url("/foo/bar"))?.open(), "Hello, world!")
        XCTAssertNil(router.route(url("/foo/bar", host: "example.net")))
    }

    func testMergedAllowedHosts() {
        let router = Router<_, String>(defaultAllowedHosts: ["example.com"])
        router.register(#//foo/bar/#, allowedHosts: .merge(["example.net"])) { _ in "Hello, world!" }
        XCTAssertEqual(router.route(url("/foo/bar"))?.open(), "Hello, world!")
        XCTAssertEqual(router.route(url("/foo/bar", host: "example.net"))?.open(), "Hello, world!")
        XCTAssertNil(router.route(url("/foo/bar", host: "example.org")))
    }
}
