import NIOCore
import NIOHTTP1

extension HTTP.Client1
{
    @frozen public
    struct Request:Sendable
    {
        public
        var method:HTTPMethod
        public
        var path:String
        public
        var head:HTTPHeaders
        public
        var body:ByteBuffer?

        @inlinable public
        init(method:HTTPMethod, path:String, head:HTTPHeaders, body:ByteBuffer? = nil)
        {
            self.method = method
            self.path = path
            self.head = head
            self.body = body
        }
    }
}
