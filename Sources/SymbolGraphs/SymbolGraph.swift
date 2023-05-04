@frozen public
struct SymbolGraph:Sendable
{
    //  TODO: this should be non-optional
    public
    let metadata:Metadata?

    public
    var files:Files
    public
    var nodes:Nodes

    public
    init(metadata:Metadata?)
    {
        self.metadata = metadata
        self.files = .init()
        self.nodes = .init()
    }
}
