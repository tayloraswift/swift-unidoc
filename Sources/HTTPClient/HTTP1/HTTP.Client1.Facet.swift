import NIOCore
import NIOHTTP1

extension HTTP.Client1 {
    @frozen public struct Facet: Sendable {
        @usableFromInline var head: HTTPResponseHead?
        public var body: [UInt8]

        init(head: HTTPResponseHead? = nil, body: [UInt8] = []) {
            self.head = head
            self.body = body
        }
    }
}
extension HTTP.Client1.Facet {
    @inlinable public var headers: HTTPHeaders? { self.head?.headers }

    @inlinable public var status: UInt? { self.head?.status.code }
}
