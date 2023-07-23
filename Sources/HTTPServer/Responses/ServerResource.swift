import Media
import SHA2

@frozen public
struct ServerResource:Equatable, Sendable
{
    public
    let results:Results
    public
    let content:Content
    public
    let type:MediaType
    public
    var hash:SHA256?

    @inlinable public
    init(_ results:Results, content:Content, type:MediaType, hash:SHA256? = nil)
    {
        self.results = results
        self.content = content
        self.type = type
        self.hash = hash
    }
}
