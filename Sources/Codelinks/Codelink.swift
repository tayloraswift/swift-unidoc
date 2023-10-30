@frozen public
struct CodelinkV4:Equatable, Hashable, Sendable
{
    public
    let base:Base
    public
    var path:Path
    public
    var suffix:Suffix?

    @inlinable internal
    init(base:Base, path:Path, suffix:Suffix? = nil)
    {
        self.base = base
        self.path = path
        self.suffix = suffix
    }
}
