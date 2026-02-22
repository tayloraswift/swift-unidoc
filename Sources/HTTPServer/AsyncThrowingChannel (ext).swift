import _AsyncChannel
import NIOCore
import NIOHTTP1

extension AsyncThrowingChannel<HTTPPart<HTTPRequestHead, ByteBuffer>, any Error>.Iterator {
    /// Accumulates buffers from the channel insecurely, returning nil if the accumulated
    /// data does not match the expected length. This should not be used in production modes.
    mutating func accumulateBuffers(length: Int) async throws -> [UInt8]? {
        var body: [UInt8]
        if  length == 0 {
            return []
        } else {
            body = []
            body.reserveCapacity(length)
        }

        while case .body(let buffer)? = try await self.next() {
            if  buffer.readableBytes <= length - body.count {
                buffer.withUnsafeReadableBytes { body += $0 }
            } else {
                return nil
            }

            if  length == body.count {
                return body
            }
        }

        return nil
    }
}
