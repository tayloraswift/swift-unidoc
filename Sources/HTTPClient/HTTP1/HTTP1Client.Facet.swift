import NIOCore
import NIOHTTP1

extension HTTP1Client
{
    @frozen public
    struct Facet:Sendable
    {
        public
        var head:HTTPResponseHead?
        public
        var body:[ByteBuffer]

        init(head:HTTPResponseHead? = nil, body:[ByteBuffer] = [])
        {
            self.head = head
            self.body = body
        }
    }
}
