import JSONDecoding

@frozen public
struct SymbolGraph:Sendable
{
    public
    let metadata:Metadata

    public
    init(metadata:Metadata)
    {
        self.metadata = metadata
    }
}
