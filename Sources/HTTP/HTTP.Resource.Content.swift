import MD5
import Media

extension HTTP.Resource {
    @frozen public struct Content: Equatable, Sendable {
        public var body: Body
        public var type: MediaType
        public var encoding: MediaEncoding?

        @inlinable public init(body: Body, type: MediaType, encoding: MediaEncoding? = nil) {
            self.body = body
            self.type = type
            self.encoding = encoding
        }
    }
}
extension HTTP.Resource.Content {
    public func hash() -> MD5 {
        switch self.body {
        case .binary(let buffer):   .init(hashing: buffer)
        case .buffer(let buffer):   .init(hashing: buffer.readableBytesView)
        case .string(let string):   .init(hashing: string.utf8)
        }
    }
}
