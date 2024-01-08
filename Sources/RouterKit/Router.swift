import Foundation

private let MAX_CACHE_SIZE = 10

open class Router<Context, Output> {
    public enum AllowedHosts {
        case any
        case only(Set<String>)
        case merge(Set<String>, removing: Set<String> = [])
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
    private let defaultAllowedHosts: Set<String>?

    private var routes: [AnyRoute] = []
    private var cache: [URL: Route<Output>] = [:]

    public init(context: Context, defaultAllowedHosts: Set<String>? = nil) {
        self.context = context
        self.defaultAllowedHosts = defaultAllowedHosts
    }

    open func register<PathComponents>(
        _ regex: Regex<PathComponents>,
        allowedHosts: AllowedHosts? = nil,
        handler: @escaping (Request<PathComponents>) -> Output?
    ) {
        let context = context
        let allowedHosts = allowedHosts?.resolve(with: defaultAllowedHosts) ?? defaultAllowedHosts
        let regex = regex.anchorsMatchLineEndings()
        routes.append(AnyRoute { url in
            guard allowedHosts?.checkHost(in: url) ?? true,
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
    public convenience init(defaultAllowedHosts: Set<String>? = nil) {
        self.init(context: (), defaultAllowedHosts: defaultAllowedHosts)
    }
}

private extension Router.AllowedHosts {
    func resolve(with defaults: Set<String>?) -> Set<String>? {
        switch self {
        case .any:
            return nil
        case .only(let hosts):
            return hosts
        case .merge(let hosts, removing: let removing):
            return (defaults ?? []).union(hosts).subtracting(removing)
        }
    }
}

private extension Set<String> {
    func checkHost(in url: URL) -> Bool {
        guard let host = url.host() else { return false }
        return contains(host)
    }
}
