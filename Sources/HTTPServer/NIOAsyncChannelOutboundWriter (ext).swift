import HTTP
import NIOCore
import NIOHPACK
import NIOHTTP1
import NIOHTTP2

extension NIOAsyncChannelOutboundWriter<HTTPPart<HTTPResponseHead, ByteBuffer>>
{
    func send(_ message:HTTP.ServerMessage<HTTPHeaders>) async throws
    {
        let head:HTTPResponseHead = .init(version: .http1_1,
            status: .init(statusCode: Int.init(message.status)),
            headers: message.headers)

        if  let body:ByteBuffer = message.content
        {
            try await self.write(.head(head))
            try await self.write(.body(body))
            try await self.write(.end(nil))
        }
        else
        {
            try await self.write(.head(head))
            try await self.write(.end(nil))
        }
    }
}
extension NIOAsyncChannelOutboundWriter<HTTP2Frame.FramePayload>
{
    func send(_ message:HTTP.ServerMessage<HPACKHeaders>) async throws
    {
        if  let body:ByteBuffer = message.content
        {
            try await self.write(.headers(.init(headers: message.headers)))
            try await self.write(.data(.init(data: .byteBuffer(body),
                endStream: true)))
        }
        else
        {
            try await self.write(.headers(.init(headers: message.headers,
                endStream: true)))
        }
    }
}
