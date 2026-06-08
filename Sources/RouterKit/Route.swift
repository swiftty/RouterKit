public import Foundation

public struct Route<Value>: Sendable {
    public let url: URL
    let handler: @Sendable () -> Value

    public func open() -> Value {
        handler()
    }
}
