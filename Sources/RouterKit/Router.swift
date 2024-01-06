import Foundation

private let MAX_CACHE_SIZE = 10

open class Router<Context, Output> {
    public enum AllowedHosts {
        case any
        case only(Set<String>)
    }

    public struct Request<PathComponents> {
        public var url: URLComponents
        public var path: PathComponents
        public var context: Context
    }

    private struct AnyRoute {
        var matcher: (URL) -> Route<Output>?
    }

    private let context: Context
    private let defaultAllowedHosts: AllowedHosts

    private var routes: [AnyRoute] = []
    private var cache: [URL: Route<Output>] = [:]

    public init(context: Context, defaultAllowedHosts: AllowedHosts = .any) {
        self.context = context
        self.defaultAllowedHosts = defaultAllowedHosts
    }

    open func register<PathComponents>(
        _ regex: Regex<PathComponents>,
        allowedHosts: AllowedHosts? = nil,
        handler: @escaping (Request<PathComponents>) -> Output?
    ) {
        let context = context
        let allowedHosts = allowedHosts ?? defaultAllowedHosts
        let regex = regex.anchorsMatchLineEndings()
        routes.append(AnyRoute { url in
            guard allowedHosts.checkHost(in: url),
                  let match = try? regex.wholeMatch(in: url.path()),
                  let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let output = handler(Request(url: comps, path: match.output, context: context)) else { return nil }
            return Route(url: url) {
                output
            }
        })
    }

    open func route(_ url: URL) -> Route<Output>? {
        if let routing = cache[url] {
            return routing
        }

        for routing in routes {
            if let routing = routing.matcher(url) {
                if cache.count > MAX_CACHE_SIZE, let key = cache.keys.randomElement() {
                    cache.removeValue(forKey: key)
                }
                cache[url] = routing
                return routing
            }
        }
        return nil
    }
}

extension Router where Context == Void {
    public convenience init(defaultAllowedHosts: AllowedHosts = .any) {
        self.init(context: (), defaultAllowedHosts: defaultAllowedHosts)
    }
}

private extension Router.AllowedHosts {
    func checkHost(in url: URL) -> Bool {
        switch self {
        case .any:
            return true
        case .only(let hosts):
            guard let host = url.host() else { return false }
            return hosts.contains(host)
        }
    }
}
