@frozen public
struct SymbolGraph:Sendable
{
    //  TODO: this should be non-optional
    public
    let metadata:Metadata?

    public
    var scalars:Scalars
    public
    var files:Files

    public
    init(metadata:Metadata?)
    {
        self.metadata = metadata
        self.scalars = .init()
        self.files = .init()
    }
}
