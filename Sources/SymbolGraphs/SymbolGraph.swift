@frozen public
struct SymbolGraph:Sendable
{
    public
    let metadata:Metadata
    public
    var scalars:Scalars

    public
    init(metadata:Metadata)
    {
        self.metadata = metadata
        self.scalars = .init()
    }
}
