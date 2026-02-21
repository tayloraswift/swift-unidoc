import HTTP
import NIOCore
import NIOHTTP1

extension HTTP {
    final class OutboundShimHandler {
        init() {
        }
    }
}
extension HTTP.OutboundShimHandler: ChannelOutboundHandler {
    typealias OutboundIn = HTTPPart<HTTPResponseHead, ByteBuffer>
    typealias OutboundOut = HTTPPart<HTTPResponseHead, IOData>

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let part: OutboundOut
        switch self.unwrapOutboundIn(data) {
        case .head(let head):   part = .head(head)
        case .body(let body):   part = .body(.byteBuffer(body))
        case .end(let tail):    part = .end(tail)
        }

        context.write(self.wrapOutboundOut(part), promise: promise)
    }
}
