import MD5
import Media

extension HTTP
{
    @frozen public
    struct Resource:Equatable, Sendable
    {
        public
        let headers:Headers
        public
        var content:Content?
        public
        var hash:MD5?

        @inlinable public
        init(headers:Headers = .init(),
            content:Content?,
            hash:MD5? = nil)
        {
            self.headers = headers
            self.content = content
            self.hash = hash
        }
    }
}
extension HTTP.Resource:ExpressibleByStringLiteral, ExpressibleByStringInterpolation
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(content: .init(
            body: .string(stringLiteral),
            type: .text(.plain, charset: .utf8)))
    }
}
extension HTTP.Resource
{
    /// Computes and populates the resource ``hash`` if it has not already been computed, and
    /// drops the payload if it matches the given `tag`.
    public mutating
    func optimize(tag:MD5?)
    {
        let hash:MD5
        if  let precomputed:MD5 = self.hash
        {
            hash = precomputed
        }
        else if
            let content:Content = self.content
        {
            switch content.body
            {
            case .binary(let buffer):   hash = .init(hashing: buffer)
            case .buffer(let buffer):   hash = .init(hashing: buffer.readableBytesView)
            case .string(let string):   hash = .init(hashing: string.utf8)
            }

            self.hash = hash
        }
        else
        {
            return
        }

        if  case hash? = tag
        {
            self.content = nil
        }
    }
}
