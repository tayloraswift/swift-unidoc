import Media
import MD5

@frozen public
struct ServerResource:Equatable, Sendable
{
    public
    let headers:Headers
    public
    var content:Content
    public
    var type:MediaType
    public
    var hash:MD5?

    @inlinable public
    init(headers:Headers = .init(), content:Content, type:MediaType, hash:MD5? = nil)
    {
        self.headers = headers
        self.content = content
        self.type = type
        self.hash = hash
    }
}
extension ServerResource:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(content: .string(stringLiteral), type: .text(.plain, charset: .utf8))
    }
}
extension ServerResource
{
    /// Computes and populates the resource ``hash`` if it has not already been computed, and
    /// drops the payload if it matches the given ``tag``.
    public mutating
    func optimize(tag:MD5?)
    {
        let hash:MD5
        if  let precomputed:MD5 = self.hash
        {
            hash = precomputed
        }
        else
        {
            switch self.content
            {
            case .binary(let buffer):   hash = .init(hashing: buffer)
            case .buffer(let buffer):   hash = .init(hashing: buffer.readableBytesView)
            case .string(let string):   hash = .init(hashing: string.utf8)
            case .length:               return
            }

            self.hash = hash
        }

        if  case hash? = tag
        {
            self.content.drop()
        }
    }
}
