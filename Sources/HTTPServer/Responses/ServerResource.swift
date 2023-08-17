import Media
import MD5

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
    var hash:MD5?

    @inlinable public
    init(_ results:Results, content:Content, type:MediaType, hash:MD5? = nil)
    {
        self.results = results
        self.content = content
        self.type = type
        self.hash = hash
    }
}
