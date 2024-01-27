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
        var body:[UInt8]

        init(head:HTTPResponseHead? = nil, body:[UInt8] = [])
        {
            self.head = head
            self.body = body
        }
    }
}
