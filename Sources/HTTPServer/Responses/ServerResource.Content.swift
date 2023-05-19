import Media
import SHA2

extension ServerResource
{
    @frozen public
    struct Content:Equatable, Sendable
    {
        public
        let payload:Payload
        public
        let type:MediaType
        public
        let hash:SHA256?

        @inlinable public
        init(_ payload:Payload, type:MediaType, hash:SHA256? = nil)
        {
            self.payload = payload
            self.type = type
            self.hash = hash
        }
    }
}
