import NIOCore

extension HTTP {
    public protocol ClientConnection {
        func buffer(string: Substring) -> ByteBuffer
        func buffer(bytes: ArraySlice<UInt8>) -> ByteBuffer

        var remote: String { get }
    }
}
extension HTTP.ClientConnection {
    @inlinable public func buffer(string: String) -> ByteBuffer {
        /// In Swift >= 5.3, this has negligible performance penalty.
        self.buffer(string: string[...])
    }

    @inlinable public func buffer(_ body: HTTP.Resource.Content.Body) -> ByteBuffer {
        switch body {
        case .buffer(let buffer):   buffer
        case .binary(let bytes):    self.buffer(bytes: bytes)
        case .string(let string):   self.buffer(string: string)
        }
    }
}
