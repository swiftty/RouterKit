import Foundation

public struct Route<Value> {
    public var url: URL
    var handler: () -> Value

    public func open() -> Value {
        handler()
    }
}
